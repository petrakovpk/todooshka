//
//  TaskViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 22.05.2021.
//

import CoreData
import RxFlow
import RxSwift
import RxCocoa

struct TaskAttr: Equatable {
  let closed: Date?
  let description: String
  let kindOfTask: KindOfTask
  let status: TaskStatus
  let text: String
}

class TaskViewModel: Stepper {
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  // core data
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }
  
  // rx
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  // task attr
  let taskUID: String
  var closed: Date? = nil
  var status: TaskStatus = .InProgress
  
  // helpers
  var isDescriptionPlaceholderEnabled: Bool = false
  
  struct Input {

    let textTextFieldText: Driver<String>
    let textFieldEditingDidEndOnExit: Driver<Void>
    // descriptionTextField
    let descriptionTextViewText: Driver<String>
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
    let alertOkButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let clearDescriptionPlaceholder: Driver<Void>
    let configureKindsOfTask: Driver<Void>
    let dataSource: Driver<[KindOfTaskSection]>
    let descriptionTextField: Driver<String>
    let hideAlertTrigger: Driver<Void>
    let navigateBack: Driver<Void>
    let save: Driver<Result<Void,Error>>
    let setDescriptionPlaceholder: Driver<Void>
    let showAlertTrigger: Driver<Void>
    let taskIsNewTrigger: Driver<Void>
    let taskIsNotNewTrigger: Driver<Void>
    let textTextField: Driver<String>
  }
  
  //MARK: - Init
  init(services: AppServices, taskUID: String) {
    self.services = services
    self.taskUID = taskUID
  }
  
  init(services: AppServices, taskUID: String, status: TaskStatus, closed: Date?) {
    self.services = services
    self.taskUID = taskUID
    self.status = status
    self.closed = closed
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {

    // start
    let tasks = services.dataService.tasks
    let task = tasks
      .compactMap{ $0.first(where: { $0.UID == self.taskUID }) }
      .startWith(
        Task(
          UID: self.taskUID,
          text: "",
          description: "",
          kindOfTaskUID: KindOfTask.Standart.Simple.UID,
          status: self.status,
          created: Date(),
          closed: self.closed)
      )
    
    let taskIsNewTrigger = tasks
      .map{ $0.first(where: { $0.UID == self.taskUID }) }
      .filter{ $0 == nil }
      .map{ _ in () }
    
    let taskIsNotNewTrigger = tasks
      .asObservable()
      .take(1)
      .asDriver(onErrorJustReturn: [])
      .map{ $0.first(where: { $0.UID == self.taskUID }) }
      .filter{ $0 != nil }
      .map{ _ in () }
    
    // kindsOfTask
    let kindsOfTask = services.dataService
      .kindsOfTask
      .map { $0.filter { $0.status == .Active }}
    
    // dataSource
    let dataSource = Driver
      .combineLatest(task, kindsOfTask) { task, kindsOfTask -> [KindOfTaskSection] in
        [KindOfTaskSection(
          header: "",
          items: kindsOfTask.map {
            KindOfTaskItem(
              kindOfTask: $0,
              isSelected: $0.UID == task.kindOfTaskUID
            )
          }
        )]
      }
      .asDriver(onErrorJustReturn: [])
    
    // task attr
    let savedKindfOfTask = task
      .withLatestFrom(kindsOfTask){ task, kindsOfTask -> KindOfTask in
        kindsOfTask.first(where: { $0.UID == task.kindOfTaskUID }) ?? KindOfTask.Standart.Simple
      }
    
    let selectedKindfOfTask = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> KindOfTask in
        dataSource[indexPath.section].items[indexPath.item].kindOfTask
      }
    
    let kindOfTask = Driver.of(savedKindfOfTask, selectedKindfOfTask).merge()

    let text = Driver
      .of( task.compactMap{ $0.text }, input.textTextFieldText )
      .merge()
    
    let description = Driver
      .of(
        task.compactMap{ $0.description }.distinctUntilChanged(),
        input.descriptionTextViewText.filter{ _ in self.isDescriptionPlaceholderEnabled == false }
      ).merge()
    
    let status = Driver
      .of(
        task.compactMap{ $0.status }.distinctUntilChanged(),
        input.alertOkButtonClickTrigger.map{ TaskStatus.Completed }
      ).merge()
    
    let closed = input.alertOkButtonClickTrigger
      .map{ Date() }
      .startWith(nil)
    
    let taskAttr = Driver
      .combineLatest(text, description, kindOfTask, status, closed) { text, description, kindOfTask, status, closed in
        TaskAttr(closed: closed, description: description, kindOfTask: kindOfTask, status: status, text: text)
      }.distinctUntilChanged()
    
    // description
    let setDescriptionPlaceholder = Driver
      .of(
        // Это как бы старт
        task.map{ $0.description ?? "" }.asObservable().take(1).asDriver(onErrorJustReturn: ""),
        // Это когда перестаем редактировать
        input.descriptionTextViewDidEndEditing.withLatestFrom(description){ $1 }
      ).merge()
      .filter{ $0.isEmpty }
      .map{ _ in () }
      .do{ _ in self.isDescriptionPlaceholderEnabled = true }
    
    let clearDescriptionPlaceholder = input.descriptionTextViewDidBeginEditing
      .compactMap{ self.isDescriptionPlaceholderEnabled ? () : nil   }
      .do{ _ in self.isDescriptionPlaceholderEnabled = false }
      
    // save
    let selectionTrigger = input.selection
      .map{ _ in () }
    
    let save = Driver
      .of(
        input.textFieldEditingDidEndOnExit,
        input.saveTaskButtonClickTrigger,
        input.alertOkButtonClickTrigger,
        selectionTrigger
      ).merge()
      .withLatestFrom(task){ $1 }
      .withLatestFrom(taskAttr) { task, taskAttr -> Task in
        Task(
          UID: task.UID,
          text: taskAttr.text,
          description: taskAttr.description,
          kindOfTaskUID: taskAttr.kindOfTask.UID,
          status: taskAttr.status,
          created: task.created,
          closed: taskAttr.closed
        )
      }.asObservable()
      .flatMapLatest({ self.managedContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let showAlertTrigger = input.completeButtonClickTrigger
    let hideAlertTrigger = input.alertOkButtonClickTrigger

    // configure task button click
    let configureKindsOfTask = input.configureTaskTypesButtonClickTrigger
      .map {  self.steps.accept(AppStep.TaskTypesListIsRequired) }
    
    //  navigateBack
    let navigateBack = Driver
      .of(
        input.saveTaskButtonClickTrigger,
        input.textFieldEditingDidEndOnExit,
        input.backButtonClickTrigger,
        hideAlertTrigger
      )
      .merge()
      .map {  self.steps.accept(AppStep.TaskProcessingIsCompleted) }

    return Output(
      clearDescriptionPlaceholder: clearDescriptionPlaceholder,
      configureKindsOfTask: configureKindsOfTask,
      dataSource: dataSource,
      descriptionTextField: description,
      hideAlertTrigger: hideAlertTrigger,
      navigateBack: navigateBack,
      save: save,
      setDescriptionPlaceholder: setDescriptionPlaceholder,
      showAlertTrigger: showAlertTrigger,
      taskIsNewTrigger: taskIsNewTrigger,
      taskIsNotNewTrigger: taskIsNotNewTrigger,
      textTextField: text
    )
  }
}
