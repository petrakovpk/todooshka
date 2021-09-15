//
//  TaskViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 22.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Firebase
import UIKit

enum TaskFlowAction {
  case createTask(status: TaskStatus, closedDate: Date?)
  case showTask(task: Task)
}

class TaskViewModel: Stepper {
  
  //MARK: - Properties
  let disposeBag = DisposeBag()
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  let task = BehaviorRelay<Task?>(value: nil)
  let dataSource = BehaviorRelay<[TaskTypeListSectionModel]>(value: [])
  
  var status: TaskStatus?
  var closedDate: Date?
  
  //MARK: - Input - From ViewController to ViewModel
  let taskTextInput = BehaviorRelay<String?>(value: nil)
  let taskDescriptionInput = BehaviorRelay<String?>(value: nil)
  let taskTypeInput = BehaviorRelay<TaskType?>(value: nil)
  
  //MARK: - Output - From ViewModel to ViewController
  let taskTextOutput = BehaviorRelay<String?>(value: nil)
  let taskDescriptionOutput = BehaviorRelay<String?>(value: nil)
  let taskTypeOutput = BehaviorRelay<TaskType?>(value: nil)
  let errorLabelOutput = BehaviorRelay<String?>(value: nil)
  
  //MARK: - Init
  init(services: AppServices, taskFlowAction: TaskFlowAction) {
    self.services = services
    
    switch taskFlowAction {
    case .createTask(let status, let closedDate):
      self.status = status
      self.closedDate = closedDate
      self.task.accept(nil)
    case .showTask(let task):
      self.task.accept(task)
    }
    
    bindOutputs()
    bindInputs()
  }
  
  deinit {
    services.coreDataService.selectedTaskType.accept(nil)
  }
  
  //MARK: - Lifecycle
  func viewDidDisappear() {
    services.coreDataService.selectedTaskType.accept(nil)
  }
  
  //MARK: - Bind
  func bindInputs() {
    services.coreDataService.taskTypes.map{ $0.filter{ $0.status == .active }}.bind{[weak self] types in
      guard let self = self else { return }
      self.dataSource.accept([TaskTypeListSectionModel(header: "", items: types)])
    }.disposed(by: disposeBag)
    
    taskTextInput.bind{ [weak self] text in
      guard let self = self else { return }
      guard let text = text else { return }
      if text != self.taskTextOutput.value {
        self.taskTextOutput.accept(text)
      }
    }.disposed(by: disposeBag)
    
    taskDescriptionInput.bind{ [weak self] description in
      guard let self = self else { return }
      guard let description = description else { return }
      if description != self.taskDescriptionOutput.value {
        self.taskDescriptionOutput.accept(description)
      }
    }.disposed(by: disposeBag)
    
    taskTypeInput.bind{ [weak self] type in
      guard let self = self else { return }
      guard let type = type else { return }
      self.errorLabelOutput.accept("")
      if let task = self.task.value {
        task.type = type.identity
        self.services.coreDataService.saveTasksToCoreData(tasks: [task], completion: nil)
      }
      
      if type != self.taskTypeOutput.value {
        self.taskTypeOutput.accept(type)
      }
    }.disposed(by: disposeBag)
  }
  
  func bindOutputs() {
    
    task.bind{ [weak self] task in
      guard let self = self else { return }
      guard let task = task else { return }
      if task.text != self.taskTextOutput.value {
        self.taskTextOutput.accept(task.text)
      }
      if task.taskType != self.taskTypeOutput.value {
        self.taskTypeOutput.accept(task.taskType)
      }
      if task.description != self.taskDescriptionOutput.value {
        self.taskDescriptionOutput.accept(task.description)
      }
    }.disposed(by: disposeBag)
  }
  
  //MARK: - Handlers
  func completeButtonClick() {
    guard let task = task.value else { return }
    task.status = .completed
    task.closedTimeIntervalSince1970 = Date().timeIntervalSince1970
    services.coreDataService.saveTasksToCoreData(tasks: [task]) { [weak self] error in
      guard let self = self else { return }
      if let error = error {
        print(error)
        return
      }
      self.steps.accept(AppStep.taskProcessingIsCompleted)
    }
  }
  
  func saveTextButtonClick() {
    guard let task = task.value else { return }
    guard let text = taskTextOutput.value else { return }
    task.text = text
    services.coreDataService.saveTasksToFirebase(tasks: [task], completion: nil)
  }
  
  func saveDescriptionButtonClick() {
    guard let task = task.value else { return }
    guard let description = taskDescriptionOutput.value else { return }
    task.description = description
    services.coreDataService.saveTasksToCoreData(tasks: [task], completion: nil)
  }
  
  func configureTaskTypesButtonClick() {
    steps.accept(AppStep.taskTypesListIsRequired)
  }
  
  func leftBarButtonBackItemClick(){
    steps.accept(AppStep.taskProcessingIsCompleted)
  }
  
  func rightBarButtonSaveItemClick() {
    if let type = taskTypeOutput.value {
      let task = task.value ??
        Task(UID: UUID().uuidString
             , text: taskTextOutput.value ?? ""
             , description: taskDescriptionOutput.value ?? ""
             , type: type.identity
             , status: status ?? .created
             , createdTimeIntervalSince1970: closedDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 )
      
      task.type = type.identity
      task.closedTimeIntervalSince1970 = closedDate?.timeIntervalSince1970
      
      services.coreDataService.saveTasksToCoreData(tasks: [task]) {[weak self] error in
        guard let self = self else { return }
        if let error = error {
          print(error)
          return
        }
        
        self.steps.accept(AppStep.taskProcessingIsCompleted)
      }
    } else if taskTextOutput.value == "" {
      steps.accept(AppStep.taskProcessingIsCompleted)
    } else {
      self.errorLabelOutput.accept("Выберите тип")
    }
  }
}
