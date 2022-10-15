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
  let planned: Date?
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
  var planned: Date? = Date()
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
    let completeButtonClickTrigger: Driver<Void>
    let configureTaskTypesButtonClickTrigger: Driver<Void>
    let datePickerButtonClickTrigger: Driver<Void>
    let saveTaskButtonClickTrigger: Driver<Void>
    // alert
    let alertOkButtonClickTrigger: Driver<Void>
    // datePicker
    let alertDatePickerCancelButtonClick: Driver<Void>
    let alertDatePickerDate: Driver<Date>
    let alertDatePickerOKButtonClick: Driver<Void>
    
  }
  
  struct Output {
    let clearDescriptionPlaceholder: Driver<Void>
    let configureKindsOfTask: Driver<Void>
    let dataSource: Driver<[KindOfTaskSection]>
    let datePickerDate: Driver<Date>
    let descriptionTextField: Driver<String>
    let hideAlertTrigger: Driver<Void>
    let navigateBack: Driver<Void>
    let plannedText: Driver<String>
    let save: Driver<Result<Void,Error>>
    let setDescriptionPlaceholder: Driver<Void>
    let showComleteAlertTrigger: Driver<Void>
    let showDatePickerAlertTrigger: Driver<Void>
    let taskIsNewTrigger: Driver<Void>
    let taskIsNotNewTrigger: Driver<Void>
    let textTextField: Driver<String>
  }
  
  //MARK: - Init
  init(services: AppServices, taskUID: String) {
    self.services = services
    self.taskUID = taskUID
  }
  
  init(services: AppServices, taskUID: String, status: TaskStatus, planned: Date?) {
    self.services = services
    self.taskUID = taskUID
    self.status = status
    self.planned = planned
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
          closed: nil,
          planned: self.planned
        )
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
    
    let startPlanned = task
      .compactMap{ $0.planned }

    let selectedPlanned = input.alertDatePickerOKButtonClick
      .withLatestFrom(input.alertDatePickerDate) { $1 }
      
    let planned = Driver
      .of(selectedPlanned, startPlanned)
      .merge()
      .map { date -> Date? in date }
      .startWith(nil)

    let plannedText = planned
      .compactMap{ $0 }
      .compactMap{ Calendar.current.isDate($0, inSameDayAs: Date()) ?
        "Сегодня" : self.services.preferencesService.midFormatter.string(for: $0)
      }.startWith( "Когда-то" )
      
    let changeStatusToPlanned = selectedPlanned
      .withLatestFrom(task) { planned, task -> TaskStatus? in
        planned.startOfDay > Date().startOfDay && task.status != .Idea ? TaskStatus.Planned : nil
      }.compactMap{ $0 }
    
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
        input.alertOkButtonClickTrigger.map{ TaskStatus.Completed },
        changeStatusToPlanned
      ).merge()
    
    let startClosed = task.map{ $0.closed }
    let alertClosed = input.alertOkButtonClickTrigger
      .map{ Date() }
      .map{ date -> Date? in date }
    
    let closed = Driver
      .of(startClosed, alertClosed)
      .merge()
      
    
    let taskAttr = Driver
      .combineLatest(text, description, kindOfTask, planned, status, closed) { text, description, kindOfTask, planned, status, closed in
        TaskAttr(closed: closed, description: description, kindOfTask: kindOfTask, planned: planned, status: status, text: text)
      }.distinctUntilChanged()
    
    // description
    let setDescriptionPlaceholder = Driver
      .of(
        // Это как бы старт
        task.map{ $0.description ?? "" }.asObservable().take(1).asDriver(onErrorJustReturn: ""),
        // Это когда перестаем редактировать
        input.descriptionTextViewDidEndEditing.withLatestFrom(description){ $1 }
      ).merge()
      .filter { $0.isEmpty }
      .map { _ in () }
      .do { _ in self.isDescriptionPlaceholderEnabled = true }
    
    let clearDescriptionPlaceholder = input.descriptionTextViewDidBeginEditing
      .compactMap{ self.isDescriptionPlaceholderEnabled ? () : nil   }
      .do{ _ in self.isDescriptionPlaceholderEnabled = false }
      
    // save
    let save = Driver
      .of(
        input.textFieldEditingDidEndOnExit,
        input.saveTaskButtonClickTrigger,
        input.alertOkButtonClickTrigger,
        input.selection.map{ _ in () },
        input.alertDatePickerOKButtonClick
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
          closed: taskAttr.closed,
          planned: taskAttr.planned
        )
      }.asObservable()
      .flatMapLatest({ self.managedContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let showComleteAlertTrigger = input.completeButtonClickTrigger
    let showDatePickerAlertTrigger = input.datePickerButtonClickTrigger
    
    let hideAlertTrigger = Driver.of(
      input.alertOkButtonClickTrigger,
      input.alertDatePickerCancelButtonClick,
      input.alertDatePickerOKButtonClick
    ).merge()
      
    // configure task button click
    let configureKindsOfTask = input.configureTaskTypesButtonClickTrigger
      .map { self.steps.accept(AppStep.TaskTypesListIsRequired) }
    
    let datePickerDate = planned
      .compactMap{ $0 }
      .startWith(Date())
    
    //  navigateBack
    let navigateBack = Driver
      .of(
        input.saveTaskButtonClickTrigger,
        input.textFieldEditingDidEndOnExit,
        input.backButtonClickTrigger,
        input.alertOkButtonClickTrigger
      )
      .merge()
      .map { self.steps.accept(AppStep.TaskProcessingIsCompleted) }

    return Output(
      clearDescriptionPlaceholder: clearDescriptionPlaceholder,
      configureKindsOfTask: configureKindsOfTask,
      dataSource: dataSource,
      datePickerDate: datePickerDate,
      descriptionTextField: description,
      hideAlertTrigger: hideAlertTrigger,
      navigateBack: navigateBack,
      plannedText: plannedText,
      save: save,
      setDescriptionPlaceholder: setDescriptionPlaceholder,
      showComleteAlertTrigger: showComleteAlertTrigger,
      showDatePickerAlertTrigger: showDatePickerAlertTrigger,
      taskIsNewTrigger: taskIsNewTrigger,
      taskIsNotNewTrigger: taskIsNotNewTrigger,
      textTextField: text
    )
  }
}
