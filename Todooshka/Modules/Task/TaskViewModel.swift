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
  var type: TaskType
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
    let configureTaskTypesButtonClick: Driver<Void>
    
    // back
    let navigateBack: Driver<Void>
    
    // alert
    let showAlert: Driver<Void>
    let hideAlert: Driver<Void>

    // save
    let saveTask: Driver<Task>
    
    // point
    let getPoint: Driver<Task>
    
    // egg
    let createEgg: Driver<Task>
    let removeEgg: Driver<Task>
    
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
      self.type = TaskType.Standart.Empty
    case .show(let task):
      self.task = task
      self.taskIsNew = false
      self.type = services.typesService.types.value.first(where: { $0.UID == task.typeUID }) ?? TaskType.Standart.Empty
    }
    
    // Убираем все типы, которые были выбраны
    for var selectedType in services.typesService.types.value.filter({ $0.isSelected }) {
      selectedType.isSelected = false
      services.typesService.saveTypesToCoreData(types: [selectedType])
    }
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    
    // task in new
    let taskIsNew = Driver<Bool>.just(self.taskIsNew)
    
    // text
    let text = input.text
      .startWith(self.task.text)
    
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
    
    // descriptionWithPlaceholder
    let descriptionWithPlaceholder = showDescriptionPlaceholder
      .withLatestFrom(description) { ($0, $1) }
    
    // types
    let types = services.typesService.types
      .map { $0.filter { $0.status == .active } }
      .asDriver(onErrorJustReturn: [])
    
    let selectedType = types
      .map { $0.filter { $0.isSelected }.first ?? .Standart.Empty }
    
    // dataSource
    let dataSource = types
      .map { [TaskTypeListSectionModel(header: "", items: $0)] }
      .asDriver(onErrorJustReturn: [])
    
    // selection
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> TaskType in
        return dataSource[indexPath.section].items[indexPath.item] }
      .startWith(self.type)
      .withLatestFrom(selectedType) { newSelectedType, oldSelectedType -> TaskType in
        var newSelectedType = newSelectedType
        var oldSelectedType = oldSelectedType
        
        newSelectedType.isSelected = true
        oldSelectedType.isSelected = false
        
        self.services.typesService.saveTypesToCoreData(types: [oldSelectedType, newSelectedType])

        return newSelectedType
      }
    
    let isCompleted = input.completeButtonClickTrigger
      .map { true }
      .startWith(false)
    
    // task
    let task = Driver<Task>
      .combineLatest(text, description, selection, isCompleted) { (text, description, type, isCompleted) -> Task in
        return Task(
          UID: self.task.UID,
          text: text,
          description: description,
          type: type,
          status: isCompleted ? .Completed : self.task.status,
          created: self.task.created,
          closed: isCompleted ? Date() : nil
        )
      }
      .startWith(self.task)
    
    // configure task button click
    let configureTaskTypeButtonClick = input.configureTaskTypesButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.TaskTypesListIsRequired)
      }

    // save
    let saveTaskTrigger = Driver
      .of(
        input.saveTaskButtonClickTrigger,
        input.textFieldEditingDidEndOnExit,
        input.completeButtonClickTrigger,
        selection.map { _ in return () }
      )
      .merge()
      
    let saveTask = saveTaskTrigger
      .withLatestFrom(task) { $1 }
      .filter{ $0.text.isEmpty == false }
      .asObservable()
      .save(with: services)
      .asDriver(onErrorJustReturn: .emptyTask)
    
    // egg
    let createEgg = saveTask
      .filter{ self.taskIsNew && $0.status == .Created }
      .do { task in
        self.services.birdService.createEgg(task: task)
      }
    
    let removeEgg = input.completeButtonClickTrigger
      .withLatestFrom(task) { $1 }
      .asDriver()
      .do { task in
        self.services.birdService.removeEgg(task: task)
      }
    
    // добавляем пойнт
    let getPoint = input.completeButtonClickTrigger
      .withLatestFrom(task) { $1 }
      .asDriver()
      .do { task in
        self.services.pointService.createPoint(task: task)
      }
    
    // navigateBack
    let navigateBack = Driver
      .of(
        input.saveTaskButtonClickTrigger,
        input.textFieldEditingDidEndOnExit,
        input.backButtonClickTrigger,
        input.alertCompleteTaskOkButtonClickTrigger
      )
      .merge()
      .do { _ in
        self.steps.accept(AppStep.TaskProcessingIsCompleted)
      }
    
    // alert
    let showAlert = input.completeButtonClickTrigger
    let hideAlert = input.alertCompleteTaskOkButtonClickTrigger
   
    return Output(
      // text
      text: text,
      // descriptionTextField
      descriptionWithPlaceholder: descriptionWithPlaceholder,
      // collectionView
      dataSource: dataSource,
      selection: selection,
      // buttons
      configureTaskTypesButtonClick: configureTaskTypeButtonClick,
      // back
      navigateBack: navigateBack,
      // Complete Task Alert
      showAlert: showAlert,
      hideAlert: hideAlert,
      // save
      saveTask: saveTask,
      // point
      getPoint: getPoint,
      // egg
      createEgg: createEgg,
      removeEgg: removeEgg,
      // taskIsNew
      taskIsNew: taskIsNew
    )
  }
}
