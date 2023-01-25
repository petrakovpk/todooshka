//
//  TaskViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 22.05.2021.
//

import CoreData
import RxFlow
import RxGesture
import RxCocoa
import RxSwift
import YandexMobileMetrica

class TaskViewModel: Stepper {
  
  public let steps = PublishRelay<Step>()
  
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  private let disposeBag = DisposeBag()
  private let services: AppServices
  private let isModal: Bool

  private var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }
  private var task: Task
  private var isDescriptionPlaceholderEnabled = false

  struct Input {
    // back
    let backButtonClickTrigger: Driver<Void>
    // text
    let nameTextField: Driver<String>
    let nameTextFieldEditingDidEndOnExit: Driver<Void>
    let saveNameTextFieldButtonClickTrigger: Driver<Void>
    // expected DateTime
    let expectedDateButtonClickTrigger: Driver<Void>
    let expectedDate: Driver<Date>
    let expectedDatePickerClearButtonClickTrigger: Driver<Void>
    let expectedDatePickerOkButtonClickTrigger: Driver<Void>
    let expectedDatePickerBackgroundClickTrigger: Driver<Void>
    let expectedTimeButtonClickTrigger: Driver<Void>
    let expectedTime: Driver<Date>
    let expectedTimePickerClearButtonClickTrigger: Driver<Void>
    let expectedTimePickerOkButtonClickTrigger: Driver<Void>
    let expectedTimePickerBackgroundClickTrigger: Driver<Void>
    // kindOfTask Settings
    let kindOfTaskSettingsButtonClickTrigger: Driver<Void>
    let kindOfTaskSelection: Driver<IndexPath>
    // description
    let descriptionTextView: Driver<String>
    let descriptionTextViewDidBeginEditing: Driver<Void>
    let descriptionTextViewDidEndEditing: Driver<Void>
    let saveDescriptionTextViewButtonClickTrigger: Driver<Void>
    // resultImageView
    let resultImageViewClickTrigger: Driver<Void>
    // bottom buttons
    let addTaskButtonClickTrigger: Driver<Void>
    let completeButtonClickTrigger: Driver<Void>
    let getPhotoButtonClickTrigger: Driver<Void>
  }

  struct Output {
    // INIT
    let initData: Driver<Task>
    let taskIsNew: Driver<Bool>
    let isModal: Driver<Bool>
    // BACK
    let navigateBack: Driver<Void>
    // TEXT
    let saveNameTextFieldButtonIsHidden: Driver<Bool>
    let saveText: Driver<Result<Void, Error>>
    // EXPECTED DATE
    let expectedDateTime: Driver<Date>
    let openExpectedDatePickerTrigger: Driver<Void>
    let closeExpectedDatePickerTrigger: Driver<Void>
    let openExpectedTimePickerTrigger: Driver<Void>
    let closeExpectedTimePickerTrigger: Driver<Void>
    let scrollToTodayDatePickerTrigger: Driver<Date>
    let scrollToEndOfDateTimePickerTrigger: Driver<Date>
    let saveExpectedDate: Driver<Result<Void, Error>>
    let saveExpectedTime: Driver<Result<Void, Error>>
    // KINDOFTASK
    let openKindOfTaskSettings: Driver<Void>
    let dataSource: Driver<[KindOfTaskSection]>
    let selectKindOfTask: Driver<Result<Void, Error>>
    // DESCRIPTION
    let hideDescriptionPlaceholder: Driver<Void>
    let showDescriptionPlaceholder: Driver<Void>
    let saveDescriptionTextViewButtonIsHidden: Driver<Bool>
    let saveDescription: Driver<Result<Void, Error>>
    // COMPLETE
    let completeTask: Driver<Result<Void, Error>>
    // CLOSE VIEW CONTROLLER
    let dismissViewController: Driver<Void>
    //
    // yandex
    // let yandexMetrika: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, task: Task, isModal: Bool) {
    self.services = services
    self.task = task
    self.isModal = isModal
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let initData = Driver.just(self.task)
    let tasks = services.dataService.tasks
    let isModal = Driver.just(self.isModal)
    
    let taskIsNew = tasks
      .map { tasks -> Bool in
        !tasks.contains { $0.UID == self.task.UID }
      }
      .asObservable()
      .take(1)
      .asDriverOnErrorJustComplete()
    
    let task = tasks
      .compactMap { $0.first { $0.UID == self.task.UID } }
      .startWith(self.task)
    
    let kindsOfTask = services.dataService
      .kindsOfTask
      .map { $0.filter { $0.status == .active } }
    
    // MARK: - BACK
    let navigateBack = input.backButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.navigateBack) }
    
    // MARK: - TEXT
    let text = input
      .nameTextField
    
    let saveNameTextFieldButtonIsHidden = Driver
      .combineLatest(text, task) { text, task -> Bool in
        task.text == text
      }
    
    let saveText = Driver
      .of(
        input.saveNameTextFieldButtonClickTrigger,
        input.nameTextFieldEditingDidEndOnExit,
        input.addTaskButtonClickTrigger )
      .merge()
      .withLatestFrom(text)
      .withLatestFrom(task) { text, task -> Task in
        var task = task
        task.text = text
        return task
      }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
    
    // MARK: - EXPECTED DATE
    let expectedDateTime = task
      .compactMap { $0.planned }
    
    let openExpectedDatePickerTrigger = input.expectedDateButtonClickTrigger

    let closeExpectedDatePickerTrigger = Driver.of(
      input.expectedDatePickerBackgroundClickTrigger,
      input.expectedDatePickerOkButtonClickTrigger )
      .merge()
    
    let scrollToTodayDatePickerTrigger = input.expectedDatePickerClearButtonClickTrigger
      .map { Date() }
    
    let expectedDate = Driver.of(
      input.expectedDate,
      scrollToTodayDatePickerTrigger )
      .merge()
    
    let saveExpectedDate = input.expectedDatePickerOkButtonClickTrigger
      .withLatestFrom(expectedDate)
      .withLatestFrom(task) { expectedDate, task -> Task in
        var task = task
        let constDate = task.planned
        let constTime = Int(constDate.timeIntervalSince1970 - constDate.startOfDay.timeIntervalSince1970)
        task.planned = expectedDate.startOfDay.adding(.second, value: constTime)
        return task
      }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
    
    // MARK: - EXPECTED TIME
    let openExpectedTimePickerTrigger = input.expectedTimeButtonClickTrigger
    
    let closeExpectedTimePickerTrigger = Driver.of(
      input.expectedTimePickerBackgroundClickTrigger,
      input.expectedTimePickerOkButtonClickTrigger )
      .merge()
     
    let scrollToEndOfDateTimePickerTrigger = input.expectedTimePickerClearButtonClickTrigger
      .map { Date().endOfDay.roundToTheBottomMinute }
    
    let expectedTime = Driver.of(
      input.expectedTime,
      scrollToEndOfDateTimePickerTrigger
    )
      .merge()
    
    let saveExpectedTime = input.expectedTimePickerOkButtonClickTrigger
      .withLatestFrom(expectedTime)
      .withLatestFrom(task) { expectedTime, task -> Task in
        var task = task
        let constDate = task.planned.startOfDay
        let deltaSeconds = Int(expectedTime.timeIntervalSince1970 - expectedTime.startOfDay.timeIntervalSince1970)
        task.planned = constDate.adding(.second, value: deltaSeconds)
        return task
      }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
    
    // MARK: - KINDOFTASK
    let openKindOfTaskSettings = input.kindOfTaskSettingsButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.kindsOfTaskListIsRequired) }
    
    let dataSource = Driver
      .combineLatest(task, kindsOfTask) { task, kindsOfTask -> [KindOfTaskSection] in
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
    
    // MARK: - DESCRIPTION
    let description = input
      .descriptionTextView
      .map { self.isDescriptionPlaceholderEnabled ? "" : $0 }
    
    let saveDescriptionTextViewButtonIsHidden = Driver.combineLatest(description, task) { description, task -> Bool in
      description == task.description
    }

    let showDescriptionPlaceholderWhenStart = Driver
      .just(self.task.description)
      .filter { $0.isEmpty }
    
    let showDescriptionPlaceholderWhenEndEditing = input.descriptionTextViewDidEndEditing
      .withLatestFrom(description) { $1 }
      .filter { $0.isEmpty }
    
    let showDescriptionPlaceholder = Driver.of(
      showDescriptionPlaceholderWhenStart,
      showDescriptionPlaceholderWhenEndEditing )
      .merge()
      .mapToVoid()
      .do { _ in self.isDescriptionPlaceholderEnabled = true }
    
    let hideDescriptionPlaceholder = input.descriptionTextViewDidBeginEditing
      .filter { _ in self.isDescriptionPlaceholderEnabled }
      .do { _ in self.isDescriptionPlaceholderEnabled = false }

    let saveDescription = Driver.of(
      input.saveDescriptionTextViewButtonClickTrigger,
      input.addTaskButtonClickTrigger )
      .merge()
      .withLatestFrom(description)
      .withLatestFrom(task) { description, task -> Task in
        var task = task
        task.description = description
        return task
      }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
    
    let selectKindOfTask = input.kindOfTaskSelection
      .withLatestFrom(dataSource) { indexPath, dataSource -> KindOfTask in
        dataSource[indexPath.section].items[indexPath.item].kindOfTask
      }
      .withLatestFrom(task) { kindOfTask, task -> Task in
        var task = task
        task.kindOfTaskUID = kindOfTask.UID
        return task
      }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    // MARK: - COMPLETE
    let completeTask = input.completeButtonClickTrigger
      .withLatestFrom(task) { _, task -> Task in
        var task = task
        task.status = .completed
        task.completed = Date()
        return task
      }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let dismissViewController = Driver.of(
      input.addTaskButtonClickTrigger,
      input.nameTextFieldEditingDidEndOnExit
    )
      .merge()
      .withLatestFrom(taskIsNew)
      .filter { $0 }
      .mapToVoid()
      .do { _ in
        self.isModal ? self.steps.accept(AppStep.dismiss) :  self.steps.accept(AppStep.navigateBack)
      }

    return Output(
      // INIT
      initData: initData,
      taskIsNew: taskIsNew,
      isModal: isModal,
      // BACK
      navigateBack: navigateBack,
      // TEXT
      saveNameTextFieldButtonIsHidden: saveNameTextFieldButtonIsHidden,
      saveText: saveText,
      // EXPECTED DATE
      expectedDateTime: expectedDateTime,
      openExpectedDatePickerTrigger: openExpectedDatePickerTrigger,
      closeExpectedDatePickerTrigger: closeExpectedDatePickerTrigger,
      openExpectedTimePickerTrigger: openExpectedTimePickerTrigger,
      closeExpectedTimePickerTrigger: closeExpectedTimePickerTrigger,
      scrollToTodayDatePickerTrigger: scrollToTodayDatePickerTrigger,
      scrollToEndOfDateTimePickerTrigger: scrollToEndOfDateTimePickerTrigger,
      saveExpectedDate: saveExpectedDate,
      saveExpectedTime: saveExpectedTime,
      // KINDOFTASK
      openKindOfTaskSettings: openKindOfTaskSettings,
      dataSource: dataSource,
      selectKindOfTask: selectKindOfTask,
      // DESCRIPtiON
      hideDescriptionPlaceholder: hideDescriptionPlaceholder,
      showDescriptionPlaceholder: showDescriptionPlaceholder,
      saveDescriptionTextViewButtonIsHidden: saveDescriptionTextViewButtonIsHidden,
      saveDescription: saveDescription,
      // COMPLETE TASK
      completeTask: completeTask,
      // CLOSE VIEW CONTROLLER
      dismissViewController: dismissViewController
    )
  }
}
