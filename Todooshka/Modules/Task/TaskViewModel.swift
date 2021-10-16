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
  let type: TaskType?
  let text: String
  let description: String?
}

class TaskViewModel: Stepper {
  
  //MARK: - Properties
  var task: Task?
  
  var status: TaskStatus?
  var closedDate: Date?
  
  let steps = PublishRelay<Step>()
  let services: AppServices

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
    let errorTextLabel: Driver<String>
    let placeholderIsOn: Driver<Bool>
    
    let backButtonClick: Driver<Void>
    let configureTaskTypeButtonClick: Driver<Void>
    let completeButtonClick: Driver<Void>
    let okAlertButtonClick: Driver<Void>
    let saveButtonClick: Driver<Void>
    
    let dataSource: Driver<[TaskTypeListSectionModel]>
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
    
  }
  
  //MARK: - Lifecycle
  func viewDidDisappear() {
    services.coreDataService.selectedTaskType.accept(nil)
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    
    // MARK: - Task Description
    let placeholderIsOn = Driver.of(input.descriptionTextViewDidBeginEditing, input.descriptionTextViewDidEndEditing)
      .merge()
      .withLatestFrom(input.description)
      .map { return $0 == "" }
      .distinctUntilChanged()
      .startWith((task?.description ?? "") == "")
      .asDriver()
    
    let description = input.description.withLatestFrom(placeholderIsOn) { description, placeholderIsOn -> String in
      return placeholderIsOn ? "" : description
    }.asDriver().startWith(task?.description ?? "")
    
    //MARK: - DataSource
    let dataSource = services.coreDataService.taskTypes
      .map { $0.filter { $0.status == .active }}
      .map { types -> [TaskTypeListSectionModel] in
        return [TaskTypeListSectionModel(header: "", items: types)]
      }.asDriver(onErrorJustReturn: [])
    
    // MARK: - Task Type
    let typeCellClicked = input.selection.withLatestFrom(dataSource)
      { (indexPath, dataSource) -> TaskType? in
      let type = dataSource[indexPath.section].items[indexPath.item]

      if let task = self.task {
        task.typeUID = type.identity
        self.services.coreDataService.saveTasksToCoreData(tasks: [task], completion: nil)
      }

      self.services.coreDataService.selectedTaskType.accept(type)
      
      return type
    }.startWith(task?.type)
    
    // MARK: - Task Attr
    let taskAttr = Driver<TaskAttr>.combineLatest(
      typeCellClicked,
      input.text.startWith(task?.text ?? ""),
      description
    )
    { type, text, description -> TaskAttr in
      return TaskAttr(type: type, text: text, description: description)
    }.asDriver()
  
    // MARK: - Hanlders
    let backButtonClick = input.backButtonClickTrigger.map { () in
      self.steps.accept(AppStep.taskProcessingIsCompleted)
    }
    
    let completeButtonClick = input.completeButtonClickTrigger
    
    let configureTaskTypeButtonClick = input.configureTaskTypesButtonClickTrigger.map { _ in
      self.steps.accept(AppStep.taskTypesListIsRequired)
    }
    
    let okAlertButtonClick = input.okAlertButtonClickTrigger.map { () in
      guard let task = self.task else { return }
      task.status = .completed
      task.closedTimeIntervalSince1970 = Date().timeIntervalSince1970
      
      self.services.coreDataService.saveTasksToCoreData(tasks: [task]) { error in
        if let error = error {
          print(error.localizedDescription)
          return
        }
        self.steps.accept(AppStep.taskProcessingIsCompleted)
      }
    }
    
    let saveButtonClick = Driver.of(input.saveTaskButtonClickTrigger, input.textFieldEditingDidEndOnExit)
      .merge()
      .withLatestFrom(taskAttr) { [weak self] _, attr in
        guard let self = self else { return }
        guard let type = attr.type else { return }
        
        if self.task == nil {
          self.task = Task(UID: UUID().uuidString, text: "", description: "", typeUID: "", status: .created, createdTimeIntervalSince1970: Date().timeIntervalSince1970 )
        }
        
        guard let task = self.task else { return }
        
        task.text = attr.text
        task.typeUID = type.identity
        task.description = attr.description
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
      }
    
    // MARK: - Errors
    let errorCreated = input.saveTaskButtonClickTrigger.withLatestFrom(typeCellClicked) { (_, type) -> String in
      return type == nil ? "Выберите тип" : ""
    }.asDriver()
    
    let errorRemoved = typeCellClicked.map { type -> String in
      return ""
    }.asDriver()
    
    let errorTextLabel = Driver.of(errorCreated, errorRemoved).merge()
    
    //MARK: - Output
    return Output(
      errorTextLabel: errorTextLabel,
      placeholderIsOn: placeholderIsOn,
      backButtonClick: backButtonClick,
      configureTaskTypeButtonClick: configureTaskTypeButtonClick,
      completeButtonClick: completeButtonClick,
      okAlertButtonClick: okAlertButtonClick,
      saveButtonClick: saveButtonClick,
      dataSource: dataSource
    )
  }
}
