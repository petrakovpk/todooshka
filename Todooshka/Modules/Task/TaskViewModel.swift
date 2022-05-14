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
  var status: TaskStatus?
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
    let nameTextField: Driver<String>
    
    // descriptionLabel
    let descriptionTextView: Driver<(placeholderIsHidden: Bool, description: String)>
    
    // collectionView
    let dataSource: Driver<[TypeLargeCollectionViewCellSectionModel]>
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
    
    // actions
 //   let actions: Driver<MainTaskListSceneAction>
//    let createEgg: Driver<Task>
//    let removeEgg: Driver<Task>
    
    // is task is New?
    let taskIsNew: Driver<Bool>
  }
  
  //MARK: - Init
  init(services: AppServices, taskFlowAction: TaskFlowAction) {
    self.services = services
    switch taskFlowAction {
    case .create(let status, let closed):
      self.task = Task(
        UID: UUID().uuidString,
        text: "",
        description: "",
        type: TaskType.Standart.Empty,
        status: .Draft,
        created: Date(),
        closed: closed)
      self.taskIsNew = true
      self.status = status
    case .show(let task):
      self.task = task
      self.taskIsNew = false
    }
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {

    // task in new
    let taskIsNew = Driver<Bool>.just(self.taskIsNew)
    
    // task from CoreData
    let task = services.tasksService.tasks
      .map {
        $0.first {
          $0.UID == self.task.UID
        } ?? self.task
      }
      .asDriver(onErrorJustReturn: self.task)

//    let egg = services.actionService.eggs
//      .withLatestFrom(task) { eggs, task -> Egg? in
//        eggs.first(where: { $0.taskUID == task.UID })
//      }
    
    // text
    let text = input.text
      .startWith(self.task.text)
    
    // showDescriptionPlaceholder
    let descriptionPlaceholderIsHidden = Driver
      .of(input.descriptionTextViewDidBeginEditing, input.descriptionTextViewDidEndEditing)
      .merge()
      .withLatestFrom(input.description)
      .map { $0.isEmpty == false } // если дескрипшн пустой, то показывает плейсхолдер
      .startWith(self.task.description.isEmpty)
      .asDriver()
  
    // description
    let description = input.description
      .startWith(self.task.description)
      .withLatestFrom(descriptionPlaceholderIsHidden) { $1 ? "" : $0 }
      .asDriver()
      .distinctUntilChanged()
    
    // descriptionTextView
    let descriptionTextView = descriptionPlaceholderIsHidden
      .withLatestFrom(description) { (placeholderIsHidden: $0, description: $1) }
    
    // types
    let types = services.typesService.types
      .map {
        $0.filter {
          $0.status == .active
        }
      }
      .asDriver(onErrorJustReturn: [])
    
    // dataSource
    let dataSource = Driver.combineLatest(task, types) { task, types -> [TypeLargeCollectionViewCellSectionModel] in
      [TypeLargeCollectionViewCellSectionModel(
        header: "",
        items: types.map {
          TypeLargeCollectionViewCellSectionModelItem(
            type: $0,
            isSelected: $0.UID == task.typeUID
          )
        }
      )]
    }
      .asDriver(onErrorJustReturn: [])
    
    // selection
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> TaskType in
        return dataSource[indexPath.section].items[indexPath.item].type }
      .startWith(self.task.type(withTypeService: services) ?? TaskType.Standart.Empty)
    
    let completeTask = input.completeButtonClickTrigger
      .map { true }
      .startWith(false)
    
    // task
    let changedTask = Driver<Task>
      .combineLatest(task, text, description, selection, completeTask) { (task, text, description, type, completeTask) -> Task in
        return Task(
          UID: task.UID,
          text: text,
          description: description,
          type: type,
          status: completeTask ? .Completed : task.status,
          created: task.created,
          closed: completeTask ? Date() : task.closed
        )
      }
      .startWith(self.task)
      .asObservable()
      .asDriver(onErrorJustReturn: self.task)
    
    // configure task button click
    let configureTaskTypeButtonClick = input.configureTaskTypesButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.TaskTypesListIsRequired)
      }

    // save
    let saveTrigger = Driver
      .of(
        input.saveTaskButtonClickTrigger,
        input.textFieldEditingDidEndOnExit,
        input.completeButtonClickTrigger,
        selection.skip(1).map{ _ in () }
      )
      .merge()
          
    let save = saveTrigger
      .withLatestFrom(changedTask) { $1 }
      .distinctUntilChanged()
      .asObservable()
      .changeTaskStatus(status: self.status)
      .saveTask(service: services)
      .asDriver(onErrorJustReturn: .emptyTask)
    
    let clade = task.compactMap {
      $0.type(withTypeService: self.services)?
        .bird(withBirdService: self.services)?
        .clade
    }
    
    // actions
//    let createTheEgg = save
//      .filter{ $0.status == .InProgress && $0.is24hoursPassed == false }
//      .withLatestFrom(clade) {
//        MainTaskListSceneAction(
//          UID: UUID().uuidString,
//          action: .CreateOrUpdateTheEgg(
//            egg: Egg(
//              UID: UUID().uuidString,
//              clade: $1,
//              created: $0.created,
//              taskUID: $0.UID),
//            withAnimation: true),
//          status: .ReadyToRun
//        )
//      }
//
//    let brokeTheEgg = input.alertCompleteTaskOkButtonClickTrigger
//      .withLatestFrom(task) { $1 }
//      .map {
//        MainTaskListSceneAction(
//          UID: UUID().uuidString,
//          action: .BrokeTheEgg(taskUID: $0.UID),
//          status: .ReadyToRun
//        )
//      }
    
   // let actions = Driver<[]>.just([])
    
//    let actions = Driver.of(
//      createOrUpdateTheEgg,
//      brokeTheEgg
//    )
//      .merge()
//      .do {
//        self.services.actionService.addAction(action: $0)
//      }

    // добавляем пойнт
    let getPoint = input.completeButtonClickTrigger
      .withLatestFrom(changedTask) { $1 }
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
      nameTextField: text,
      // descriptionTextField
      descriptionTextView: descriptionTextView,
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
      saveTask: save,
      // point
      getPoint: getPoint,
      // actions
 //     actions: actions,
//      createEgg: createEgg,
//      removeEgg: removeEgg,
      // taskIsNew
      taskIsNew: taskIsNew
    )
  }
}
