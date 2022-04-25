//
//  TaskViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 22.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa

struct TaskAttr {
  let type: TaskType
  let text: String
  let description: String
}

class TaskViewModel: Stepper {
  
  private let disposeBag = DisposeBag()
  
  //MARK: - Properties
  var task: Task
  let taskIsNew: Bool
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  struct Input {
    // nameTextField
    let text: Driver<String>
    let textFieldEditingDidEndOnExit: Driver<Void>
    
    // descriptionTextField
    let description: Driver<String>
    let descriptionTextViewDidBeginEditing: Driver<Void>
    let descriptionTextViewDidEndEditing: Driver<Void>
    
    // collectionView
    let selection: Driver<IndexPath>
    
    // buttons
    let backButtonClickTrigger: Driver<Void>
    let configureTaskTypesButtonClickTrigger: Driver<Void>
    let saveTaskButtonClickTrigger: Driver<Void>
    let completeButtonClickTrigger: Driver<Void>
    
    // alert
    let alertCompleteTaskOkButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // text
    let text: Driver<String>
    
    // descriptionTextField
    let descriptionWithPlaceholder: Driver<(Bool, String)>
    
    // collectionView
    let dataSource: Driver<[TaskTypeListSectionModel]>
    let selection: Driver<TaskType>
    
    // buttons
    let backButtonClick: Driver<Void>
    let configureTaskTypesButtonClick: Driver<Void>
    let completeButtonClick: Driver<Void>
    
    // alert
    let alertOkButtonClick: Driver<Void>

    // save
    let saveTaskTrigger: Driver<Void>
    
    // is task is New?
    let taskIsNew: Driver<Bool>
  }
  
  //MARK: - Init
  init(services: AppServices, taskFlowAction: TaskFlowAction) {
    self.services = services
    switch taskFlowAction {
    case .create(let status, let closed):
      self.task = Task.emptyTask
      self.task.UID = UUID().uuidString
      self.task.status = status
      self.task.closed = closed
      self.taskIsNew = true
    case .show(let task):
      self.task = task
      self.taskIsNew = false
    }
  
    // Убираем все типы, которые были выбраны
    if var oldSelectedType = services.typesService.types.value.first(where: { $0.isSelected }) {
      oldSelectedType.isSelected = false
      services.typesService.saveTypesToCoreData(types: [oldSelectedType])
    }
    
    // Записываем выбранный тип
    if var newSelectedType = services.typesService.types.value
      .first(where: { $0.UID == self.task.typeUID }) {
      newSelectedType.isSelected = true
      services.typesService.saveTypesToCoreData(types: [newSelectedType])
    }
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    
    
    // text
    let text = input.text
      .startWith(self.task.text)
      .do { text in // ok
        self.task.text = text
      }
    
    // showDescriptionPlaceholder
    let showDescriptionPlaceholder = Driver
      .of(input.descriptionTextViewDidBeginEditing, input.descriptionTextViewDidEndEditing)
      .merge()
      .withLatestFrom(input.description)
      .map { $0.isEmpty } // если дескрипшн пустой, то показывает плейсхолдер
      .startWith(self.task.description.isEmpty)
      .asDriver()
  
    // description
    let description = input.description
      .startWith(self.task.description)
      .withLatestFrom(showDescriptionPlaceholder) { $1 ? "" : $0 }
      .asDriver()
      .distinctUntilChanged()
      .do { description in // ok
        self.task.description = description
      }
    
    // descriptionWithPlaceholder
    let descriptionWithPlaceholder = showDescriptionPlaceholder
      .withLatestFrom(description) { ($0, $1) }
    
    // types
    let types = services.typesService.types
      .map { $0.filter { $0.status == .active } }
      .asDriver(onErrorJustReturn: [])
    
    let selectedType = types
      .map {
        $0.filter {
          $0.isSelected
        }.first ?? .Standart.Empty
      }
    
    // dataSource
    let dataSource = types
      .map { [TaskTypeListSectionModel(header: "", items: $0)] }
      .asDriver(onErrorJustReturn: [])
    
    // selection
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> TaskType in
        return dataSource[indexPath.section].items[indexPath.item] }
      .withLatestFrom(selectedType) { newSelectedType, oldSelectedType -> TaskType in
        var newSelectedType = newSelectedType
        var oldSelectedType = oldSelectedType
        
        newSelectedType.isSelected = true
        oldSelectedType.isSelected = false
        
        self.services.typesService.saveTypesToCoreData(types: [oldSelectedType, newSelectedType])

        return newSelectedType
      }
      .do { type in
        guard self.task.text.isEmpty == false else { return }
        self.task.typeUID = type.UID // ok
        self.services.tasksService.saveTasksToCoreData(tasks: [self.task])
      }
    
    // task
    let task = Driver<Task>
      .combineLatest(text, description, selection) { (text, description, type) -> Task in
        return Task(UID: self.task.UID, text: text, description: description, type: type, status: self.task.status, created: self.task.created)
      }
      .startWith(self.task)
    
    // back button click
    let backButtonClick = input.backButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.TaskProcessingIsCompleted)
      }
    
    // configure task button click
    let configureTaskTypeButtonClick = input.configureTaskTypesButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.TaskTypesListIsRequired)
      }
    
    // complete button click
    let completeButtonClick = input.completeButtonClickTrigger
      .do { _ in
        self.task.status = .Completed
        self.task.closed = Date()
      }
      .do { _ in
        self.services.tasksService.saveTasksToCoreData(tasks: [self.task])
        
        if let egg = self.services.birdService.eggs
          .value
          .first(where: { $0.taskUID == self.task.UID }) {
          self.services.birdService.removeEgg(egg: egg)
        }
      }
    
    // save task
    let saveTaskTrigger = Driver
      .of(input.saveTaskButtonClickTrigger, input.textFieldEditingDidEndOnExit)
      .merge()
      .filter {
        self.task.text.isEmpty == false
      }
      .do { _ in
        if let position = self.services.birdService.getFreePosition(eggs: self.services.birdService.eggs.value),
           self.task.status == .Created {
            let egg = Egg(UID: UUID().uuidString, type: .Chiken, taskUID: self.task.UID, position: position, created: Date())
          self.services.birdService.saveEgg(egg: egg)
        }
      }
      .do { _ in
        self.services.tasksService.saveTasksToCoreData(tasks: [self.task])
        self.steps.accept(AppStep.TaskProcessingIsCompleted)
      }
    
    // alert
    let alertOkButtonClick = input.alertCompleteTaskOkButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.TaskProcessingIsCompleted)
      }
   
    // task in new
    let taskIsNew = Driver<Bool>.just(self.taskIsNew)
    
    
    
    return Output(
      // text
      text: text,
      // descriptionTextField
      descriptionWithPlaceholder: descriptionWithPlaceholder,
      // collectionView
      dataSource: dataSource,
      selection: selection,
      // buttons
      backButtonClick: backButtonClick,
      configureTaskTypesButtonClick: configureTaskTypeButtonClick,
      completeButtonClick: completeButtonClick,
      // Complete Task Alert
      alertOkButtonClick: alertOkButtonClick,
      // save
      saveTaskTrigger: saveTaskTrigger,
      // taskIsNew
      taskIsNew: taskIsNew
    )
  }
}
