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

enum TaskFlowAction {
  case createTask(status: TaskStatus, closedDate: Date?)
  case showTask(task: Task)
}

struct TaskAttr {
  let text: String
  let type: TaskType?
  let description: String?
}

class TaskViewModel: Stepper {
  
  //MARK: - Properties
  var task: Task?
  
  var status: TaskStatus?
  var closedDate: Date?
  
  let disposeBag = DisposeBag()
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  // let task = BehaviorRelay<Task?>(value: nil)
  let dataSource = BehaviorRelay<[TaskTypeListSectionModel]>(value: [])
  
  //MARK: - Input - From ViewController to ViewModel
  struct Input {
    let text: Driver<String>
    let description: Driver<String>
    let selection: Driver<IndexPath>
    
    let descriptionTextViewDidBeginEditing: Driver<Void>
    let descriptionTextViewDidEndEditing: Driver<Void>
    
    let backButtonClickTrigger: Driver<Void>
    let configureTaskTypesButtonClickTrigger: Driver<Void>
    let saveTaskButtonClickTrigger: Driver<Void>
    let saveDescriptionButtonClickTrigger: Driver<Void>
    let completeButtonClickTrigger: Driver<Void>
    let okAlertButtonClickTrigger: Driver<Void>
    let textFieldEditingDidEndOnExit: Driver<Void>
  }
  
  struct Output {
    let errorTextLabel: BehaviorRelay<String>
    let placeholderIsOn: Driver<Bool>
    let showAlertTrigger: Driver<Bool>
  }

  
  //MARK: - Init
  init(services: AppServices, taskFlowAction: TaskFlowAction) {
    self.services = services
    
    switch taskFlowAction {
    case .createTask(let status, let closedDate):
      self.status = status
      self.closedDate = closedDate
    case .showTask(let task):
      self.task = task
      services.coreDataService.selectedTaskType.accept(task.type)
    }
    
    services.coreDataService.taskTypes.map{ $0.filter{ $0.status == .active }}.bind{ [weak self] types in
      self?.dataSource.accept([TaskTypeListSectionModel(header: "", items: types)])
    }.disposed(by: disposeBag)
    
  }
  
  //MARK: - Lifecycle
  func viewDidDisappear() {
    services.coreDataService.selectedTaskType.accept(nil)
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    
    //MARK: - BehaviorRelay
    let taskText = BehaviorRelay<String>(value: "")
    let taskDescription = BehaviorRelay<String>(value: "")
    let errorTextLabel = BehaviorRelay<String>(value: "")
    let taskType = BehaviorRelay<TaskType?>(value: task?.type)
    let showAlert = BehaviorRelay<Bool>(value: false)

    //MARK: - Outputs
    let placeholderIsOn = Driver.of(input.descriptionTextViewDidBeginEditing, input.descriptionTextViewDidEndEditing)
      .merge()
      .withLatestFrom(input.description)
      .map { return $0 == "" }
      .distinctUntilChanged()
      .startWith((task?.description ?? "") == "")
      .asDriver()
  
    //MARK: - Inputs
    input.text.drive(taskText).disposed(by: disposeBag)
    input.description.withLatestFrom(placeholderIsOn) { (description, placeholderIsOn) -> String in
      return placeholderIsOn ? "" : description
    }.drive(taskDescription).disposed(by: disposeBag)
    
    input.selection.map { indexPath -> TaskType? in
      errorTextLabel.accept("")
      let type = self.dataSource.value[indexPath.section].items[indexPath.item]
      self.services.coreDataService.selectedTaskType.accept(type)
      
      if let task = self.task {
        task.typeUID = type.identity
        self.services.coreDataService.saveTasksToCoreData(tasks: [task], completion: nil)
      }
      
      return type
    }.drive(taskType).disposed(by: disposeBag)
    
    input.configureTaskTypesButtonClickTrigger.do { _ in
      self.steps.accept(AppStep.taskTypesListIsRequired)
    }.drive().disposed(by: disposeBag)
    
    input.backButtonClickTrigger.do { _ in
      self.steps.accept(AppStep.taskProcessingIsCompleted)
    }.drive().disposed(by: disposeBag)
    
    input.saveDescriptionButtonClickTrigger.withLatestFrom(input.description).do { [weak self] description in
      guard let self = self else { return }
      
      if let task = self.task {
        task.description = description
        self.services.coreDataService.saveTasksToCoreData(tasks: [task], completion: nil)
        self.task = task
      }
    }.drive().disposed(by: disposeBag)
    
    input.completeButtonClickTrigger.do { [weak self] _ in
      guard let self = self else { return }
      guard let task = self.task else { return }
      
      let taskStatusBeforeClosing = task.status
      
      task.status = .completed
      task.closedTimeIntervalSince1970 = Date().timeIntervalSince1970
      
      self.services.coreDataService.saveTasksToCoreData(tasks: [task]) { error in
        if let error = error {
          print(error.localizedDescription)
          return
        }
        
        taskStatusBeforeClosing == .created ? showAlert.accept(true) : self.steps.accept(AppStep.taskProcessingIsCompleted)
      }
    }.drive().disposed(by: disposeBag)
    
    input.okAlertButtonClickTrigger.do { [weak self] _ in
      guard let self = self else { return }
      showAlert.accept(false)
      self.steps.accept(AppStep.taskProcessingIsCompleted)
    }.drive().disposed(by: disposeBag)
    
    Driver.of(input.saveTaskButtonClickTrigger, input.textFieldEditingDidEndOnExit)
      .merge()
      .do { [weak self] _ in
      guard let self = self else { return }
      
      guard let type = taskType.value else {
        errorTextLabel.accept("Выберите тип")
        return
      }
      
      if self.task == nil {
        self.task = Task(UID: UUID().uuidString, text: "", description: "", typeUID: "", status: .created, createdTimeIntervalSince1970: Date().timeIntervalSince1970 )
      }

      guard let task = self.task else { return }

      task.text = taskText.value
      task.typeUID = type.identity
      task.description = taskDescription.value
      task.closedTimeIntervalSince1970 = self.closedDate?.timeIntervalSince1970

      if let status = self.status {
        task.status = status
      }

      self.services.coreDataService.saveTasksToCoreData(tasks: [task], completion: { error in
        if let error = error {
          print(error.localizedDescription)
          return
        }
        self.steps.accept(AppStep.taskProcessingIsCompleted)
      })
    }.drive().disposed(by: disposeBag)
    
    return Output(
      errorTextLabel: errorTextLabel,
      placeholderIsOn: placeholderIsOn,
      showAlertTrigger: showAlert.asDriver()
    )
  }
}
