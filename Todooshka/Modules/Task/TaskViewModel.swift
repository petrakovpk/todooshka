//
//  TaskViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 22.05.2021.
//

import CoreData
import RxCocoa
import RxFlow
import RxSwift
import YandexMobileMetrica

class TaskViewModel: Stepper {
  private let disposeBag = DisposeBag()

  // MARK: - Properties
  // core data
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  var managedContext: NSManagedObjectContext? { appDelegate?.persistentContainer.viewContext }

  // rx
  let steps = PublishRelay<Step>()
  let services: AppServices

  // task attr
  var task: BehaviorRelay<Task>

  // helpers
  var isDescriptionPlaceholderEnabled = false

  struct Input {
    // alert complete
    let alertOkButtonClickTrigger: Driver<Void>
    // alertDatePicker
    let alertDatePickerDate: Driver<Date>
    let alertDatePickerOKButtonClick: Driver<Void>
    let alertDatePickerCancelButtonClick: Driver<Void>
    // complete button
    let completeButtonClickTrigger: Driver<Void>
    // configure kindsOfTask button
    let configureTaskTypesButtonClickTrigger: Driver<Void>
    // collectionView
    let selection: Driver<IndexPath>
    // datePickerButton
    let datePickerButtonClickTrigger: Driver<Void>
    // descriptionTextField
    let descriptionTextView: Driver<String>
    let descriptionTextViewDidBeginEditing: Driver<Void>
    let descriptionTextViewDidEndEditing: Driver<Void>
    // header buttons
    let backButtonClickTrigger: Driver<Void>
    let saveTaskButtonClickTrigger: Driver<Void>
    // nameTextField
    let nameTextField: Driver<String>
    let nameTextFieldEditingDidEndOnExit: Driver<Void>
  }

  struct Output {
    // alert complete
    let showComleteAlertTrigger: Driver<Void>
    // alertDatePicker
    let datePickerDate: Driver<Date>
    let hideAlertTrigger: Driver<Void>
    let plannedText: Driver<String>
    let showDatePickerAlertTrigger: Driver<Void>
    // complete button
    let completeButtonIsHidden: Driver<Bool>
    // collectionView
    let dataSource: Driver<[KindOfTaskSection]>
    // descriptionTextVIew
    let hideDescriptionPlaceholder: Driver<Void>
    let showDescriptionPlaceholder: Driver<Void>
    // header buttons
    let navigateBack: Driver<Void>
    let save: Driver<Result<Void, Error>>
    // init
    let initData: Driver<Task>
    // open kindsOfTask list
    let openKindsOfTaskList: Driver<Void>
    // task
    let taskIsNew: Driver<Bool>
    // yandex
    let yandexMetrika: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, task: Task) {
    self.services = services
    self.task = BehaviorRelay<Task>(value: task)
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let initData = Driver.just(self.task.value)
    
    let name = input
      .nameTextField
    
    let description = input
      .descriptionTextView
      .map { self.isDescriptionPlaceholderEnabled ? "" : $0 }

    // description
    let showDescriptionPlaceholderWhenStart = Driver
      .just(self.task.value.description)
      .filter { $0.isEmpty }
    
    let showDescriptionPlaceholderWhenEndEditing = input.descriptionTextViewDidEndEditing
      .withLatestFrom(description) { $1 }
      .filter { $0.isEmpty }
    
    let showDescriptionPlaceholder = Driver.of(
      showDescriptionPlaceholderWhenStart,
      showDescriptionPlaceholderWhenEndEditing
    )
      .merge()
      .map { _ in () }
      .do { _ in self.isDescriptionPlaceholderEnabled = true }
    
    let hideDescriptionPlaceholder = input.descriptionTextViewDidBeginEditing
      .filter { _ in self.isDescriptionPlaceholderEnabled }
      .do { _ in self.isDescriptionPlaceholderEnabled = false }

    // kindsOfTask
    let kindsOfTask = services.dataService
      .kindsOfTask
      .map { $0.filter { $0.status == .active } }
    
    // dataSource
    let dataSource = Driver
      .combineLatest(task.asDriver(), kindsOfTask) { task, kindsOfTask -> [KindOfTaskSection] in
        [
          KindOfTaskSection(
            header: "",
            items: kindsOfTask.map {
              KindOfTaskItem(
                kindOfTask: $0,
                isSelected: $0.UID == task.kindOfTaskUID
              )
            }
          )
        ]
      }
      .asDriver(onErrorJustReturn: [])

    let startedKindOfTask = kindsOfTask
      .compactMap { kindsOfTask -> KindOfTask? in
        kindsOfTask.first { $0.UID == self.task.value.kindOfTaskUID }
      }
     
    let selectedKindfOfTask = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> KindOfTask in
        dataSource[indexPath.section].items[indexPath.item].kindOfTask
      }
    
    let kindOfTask = Driver
      .of(startedKindOfTask, selectedKindfOfTask)
      .merge()
    
    let planned = input.alertDatePickerOKButtonClick
      .withLatestFrom(input.alertDatePickerDate) { $1 }
      .startWith(self.task.value.planned)
    
    let closed = input.alertOkButtonClickTrigger
      .map { Date() }
      .startWith(self.task.value.closed)
    
    let statusPlanned = planned
      .compactMap { $0 }
      .compactMap { planned -> TaskStatus? in
        planned.startOfDay > Date().startOfDay ? .planned : nil
      }
    
    let statusCompleted = input
      .alertOkButtonClickTrigger
      .map { _ -> TaskStatus in
          .completed
      }
    
    let status = Driver
      .of(
        statusPlanned,
        statusCompleted
      )
      .merge()
      .startWith(self.task.value.status)
    
    let taskIsNew = services
      .dataService
      .tasks
      .asDriver()
      .map { tasks -> Bool in
        !tasks.contains { $0.UID == self.task.value.UID }
      }

    let task = Driver
      .combineLatest(name, description, kindOfTask, planned, closed, status) { name, description, kindOfTask, planned, closed, status -> Task in
        Task(
          UID: self.task.value.UID,
          text: name,
          description: description,
          kindOfTaskUID: kindOfTask.UID,
          status: status,
          created: self.task.value.created,
          closed: closed,
          planned: planned
        )
      }
      .do {
        self.task.accept($0)
      }
    
    let plannedText = planned
      .compactMap { $0 }
      .compactMap { Calendar.current.isDate($0, inSameDayAs: Date()) ?
        "Сегодня" : self.services.preferencesService.midFormatter.string(for: $0)
      }
      .startWith( "Когда-то" )
 
    let completeButtonIsHidden = Driver
      .combineLatest(taskIsNew, task) { taskIsNew, task -> Bool in
        taskIsNew || task.status == .completed
      }
    
    let saveTrigger = Driver
      .of(
        input.nameTextFieldEditingDidEndOnExit,
        input.saveTaskButtonClickTrigger,
        input.alertOkButtonClickTrigger,
        input.selection.map { _ in () },
        input.alertDatePickerOKButtonClick
      )
      .merge()
    
    let save = saveTrigger
      .withLatestFrom(task) { $1 }
      .asObservable()
      .flatMapLatest({ self.managedContext?.rx.update($0) ?? Observable.of(.failure(ErrorType.managedContextNotFound)) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let yandexMetrika = save
      .withLatestFrom(taskIsNew) { $1 }
      .filter { $0 }
      .withLatestFrom(task) { $1.text }
      .distinctUntilChanged()
      .map { text -> Void in
        let params: [AnyHashable: Any] = ["text": text]
        YMMYandexMetrica.reportEvent("Create Task", parameters: params, onFailure: nil)
        return ()
      }

    let showComleteAlertTrigger = input.completeButtonClickTrigger
    let showDatePickerAlertTrigger = input.datePickerButtonClickTrigger

    let hideAlertTrigger = Driver.of(
      input.alertOkButtonClickTrigger,
      input.alertDatePickerCancelButtonClick,
      input.alertDatePickerOKButtonClick
    )
      .merge()

    // configure task button click
    let openKindsOfTaskList = input.configureTaskTypesButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.kindsOfTaskListIsRequired) }

    let datePickerDate = planned
      .compactMap { $0 }
      .startWith(Date())

    //  navigateBack
    let navigateBack = Driver
      .of(
        input.saveTaskButtonClickTrigger,
        input.backButtonClickTrigger,
        input.alertOkButtonClickTrigger
      )
      .merge()
      .do { _ in self.steps.accept(AppStep.taskProcessingIsCompleted) }

    return Output(
      // alert complete
      showComleteAlertTrigger: showComleteAlertTrigger,
      // alertDatePicker
      datePickerDate: datePickerDate,
      hideAlertTrigger: hideAlertTrigger,
      plannedText: plannedText,
      showDatePickerAlertTrigger: showDatePickerAlertTrigger,
      // complete button
      completeButtonIsHidden: completeButtonIsHidden,
      // collectionView
      dataSource: dataSource,
      // descriptionTextVIew
      hideDescriptionPlaceholder: hideDescriptionPlaceholder,
      showDescriptionPlaceholder: showDescriptionPlaceholder,
      // header buttons
      navigateBack: navigateBack,
      save: save,
      // initData
      initData: initData,
      // open kindsOfTask list
      openKindsOfTaskList: openKindsOfTaskList,
      // task
      taskIsNew: taskIsNew,
      // yandex
      yandexMetrika: yandexMetrika
    )
  }
}
