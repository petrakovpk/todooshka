//
//  TaskViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//


import CoreData
import Firebase
import FirebaseStorage
import RxFlow
import RxGesture
import RxCocoa
import RxSwift
import YandexMobileMetrica
import RxAlamofire

class TaskViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  public let task: BehaviorRelay<Task>
  public let taskListMode: TaskListMode
  
  private let disposeBag = DisposeBag()
  private let services: AppServices
  
  struct Input {
    // text
    let taskTextField: Driver<String>
    let taskTextFieldEditingDidEndOnExit: Driver<Void>
    let taskTextSaveButtonClickTrigger: Driver<Void>
    // description
    let taskDescriptionTextView: Driver<String>
    let taskDescriptionSaveButtonClickTrigger: Driver<Void>
    // kinds
    let kindOfTaskSettingsButtonClickTrigger: Driver<Void>
    let kindOfTaskSelection: Driver<IndexPath>
    // expected date
    let expectedDateSelected: Driver<Date>
    let expectedDateButtonClickTrigger: Driver<Void>
    let expectedDatePickerTodayButtonClickTrigger: Driver<Void>
    let expectedDatePickerOkButtonClickTrigger: Driver<Void>
    let expectedDatePickerBackgroundClickTrigger: Driver<Void>
    // expected time
    let expectedTimeSelected: Driver<Date>
    let expectedTimeButtonClickTrigger: Driver<Void>
    let expectedTimePickerClearButtonClickTrigger: Driver<Void>
    let expectedTimePickerOkButtonClickTrigger: Driver<Void>
    let expectedTimePickerBackgroundClickTrigger: Driver<Void>
    // bottom buttons
    let createButtonClickTrigger: Driver<Void>
    let completeButtonClickTrigger: Driver<Void>
    // header buttons
    let backButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // text
    let taskTextSaveButtonIsHidden: Driver<Bool>
    // description
    let taskDescriptionSaveButtonIsHidden: Driver<Bool>
    // kindSections
    let kindSections: Driver<[KindSection]>
    let kindOpenSettings: Driver<Void>
    // expected date and expected time
    let expectedDateTime: Driver<Date>
    // expected date
    let expectedDatePickerOpen: Driver<Void>
    let expectedDatePickerClose: Driver<Void>
    let expectedDatePickerScrollToToday: Driver<Date>
    // expected time
    let expectedTimePickerOpen: Driver<Void>
    let expectedTimePickerClose: Driver<Void>
    let expectedTimePickerScrollToEndOfDay: Driver<Date>
    // bottom buttons
    let bottomButtonsMode: Driver<BottomButtonsMode>
    // save
    let taskSave: Driver<Void>
    // close
    let close: Driver<Void>
  }
  
  init(services: AppServices, task: Task, taskListMode: TaskListMode) {
    self.services = services
    self.task = BehaviorRelay<Task>(value: task)
    self.taskListMode = taskListMode
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let task = task.asDriver()
    let kinds = services.currentUserService.kinds
    let errorTracker = ErrorTracker()
    
    let taskTextSaveButtonIsHidden = Driver
      .combineLatest(input.taskTextField, task) { text, task -> Bool in
        text == task.text || task.status == .draft
      }
    
    let taskDescriptionSaveButtonIsHidden = Driver
      .combineLatest(input.taskDescriptionTextView, task) { description, task -> Bool in
        task.description == description || task.status == .draft
      }
    
    let taskTextChange = Driver.of(input.taskTextSaveButtonClickTrigger, input.createButtonClickTrigger)
      .merge()
      .withLatestFrom(input.taskTextField)
      .withLatestFrom(task) { text, task -> Task in
        var task = task
        task.text = text
        return task
      }
    
    let taskDescriptionChange = Driver.of(input.taskDescriptionSaveButtonClickTrigger, input.createButtonClickTrigger)
      .merge()
      .withLatestFrom(input.taskDescriptionTextView)
      .withLatestFrom(task) { description, task -> Task in
        var task = task
        task.description = description
        return task
      }
    
    let emptyKindItem = task
      .map { task -> KindSectionItem in
        KindSectionItem(kindSectionItemType: .emptyKind, isSelected: task.kindUUID == nil)
      }
    
    let kindItems = Driver
      .combineLatest(task, kinds) { task, kinds -> [KindSectionItem] in
        kinds.map { kind -> KindSectionItem in
          KindSectionItem(
            kindSectionItemType: .kind(kind: kind),
            isSelected: kind.uuid == task.kindUUID)
        }
      }
    
    
    let kindSections = Driver
      .combineLatest(emptyKindItem, kindItems) { emptyKindItem, kindItems -> [KindSectionItem] in
        [emptyKindItem] + kindItems
      }
      .map { items -> [KindSection] in
        [KindSection(header: "", items: items)]
      }
    
    let taskKindChange = input.kindOfTaskSelection
      .withLatestFrom(kindSections) { indexPath, sections -> KindSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
      .withLatestFrom(task) { item, task -> Task in
        var task = task
        switch item.kindSectionItemType {
        case .emptyKind:
          task.kindUUID = nil
        case .kind(let kind):
          task.kindUUID = kind.uuid
        }
        return task
      }
    
    let expectedDatePickerScrollToToday = input.expectedDatePickerTodayButtonClickTrigger
      .map { Date() }
    
    let taskExpectedDate = Driver.of(input.expectedDateSelected, expectedDatePickerScrollToToday )
      .merge()
    
    let taskExpectedDateChange = input.expectedDatePickerOkButtonClickTrigger
      .withLatestFrom(taskExpectedDate)
      .withLatestFrom(task) { expectedDate, task -> Task in
        var task = task
        let plannedTimeInSeconds = Int(task.planned.timeIntervalSince1970 - task.planned.startOfDay.timeIntervalSince1970)
        task.planned = expectedDate.startOfDay.adding(.second, value: plannedTimeInSeconds)
        return task
      }
    
    let expectedTimePickerScrollToEndOfDay = input.expectedTimePickerClearButtonClickTrigger
      .map { Date().endOfDay.roundToTheBottomMinute }
    
    let taskExpectedTime = Driver.of(input.expectedTimeSelected, expectedTimePickerScrollToEndOfDay )
      .merge()
    
    let taskExpectedTimeChange = input.expectedTimePickerOkButtonClickTrigger
      .withLatestFrom(taskExpectedTime)
      .withLatestFrom(task) { expectedTime, task -> Task in
        var task = task
        let plannedDate = task.planned.startOfDay
        let plannedTimeInSeconds = Int(expectedTime.timeIntervalSince1970 - expectedTime.startOfDay.timeIntervalSince1970)
        task.planned = plannedDate.adding(.second, value: plannedTimeInSeconds)
        return task
      }
    
    let taskDraftStatusChange = input.createButtonClickTrigger
      .withLatestFrom(task)
      .map { task -> Task in
        var task = task
        switch self.taskListMode {
        case .tabBar, .overdued:
          task.status = .inProgress
        case .idea:
          task.status = .idea
        default:
          task.status = .draft
        }
        return task
      }
    
    let taskComplete = input.completeButtonClickTrigger
      .withLatestFrom(task)
      .map { task -> Task in
        var task = task
        task.status = .completed
        task.completed = Date()
        return task
      }
    
    let taskSave = Driver.of(
      taskTextChange,
      taskDescriptionChange,
      taskKindChange,
      taskExpectedDateChange,
      taskExpectedTimeChange,
      taskDraftStatusChange,
      taskComplete
    )
      .merge()
      .do { task in
        self.task.accept(task)
      }
      .flatMapLatest { task -> Driver<Void> in
        StorageManager.shared.managedContext.rx.update(task).asDriverOnErrorJustComplete()
      }

    let kindOpenSettings = input.kindOfTaskSettingsButtonClickTrigger
      .do { [self] _ in
        steps.accept(AppStep.kindListIsRequired)
      }
    
    let expectedDateTime = task
      .compactMap { $0.planned }
 
    let expectedDatePickerOpen = input.expectedDateButtonClickTrigger

    let expectedDatePickerClose = Driver.of(
      input.expectedDatePickerBackgroundClickTrigger,
      input.expectedDatePickerOkButtonClickTrigger )
      .merge()
    
    let expectedTimePickerOpen = input.expectedTimeButtonClickTrigger
    
    let expectedTimePickerClose = Driver.of(
      input.expectedTimePickerBackgroundClickTrigger,
      input.expectedTimePickerOkButtonClickTrigger
    )
      .merge()
    
    let bottomButtonsMode = task
      .asObservable()
      .take(1)
      .asDriverOnErrorJustComplete()
      .map { task -> BottomButtonsMode in
        switch task.status {
        case .draft:
          return .create
        case .completed:
          return .publish
        default:
          return .complete
        }
      }
    
    let close = Driver.of(
      input.createButtonClickTrigger,
      input.completeButtonClickTrigger,
      input.backButtonClickTrigger
    )
      .merge()
      .map { _ -> AppStep in
        if self.taskListMode == .tabBar {
          return .dismiss
        } else {
          return .navigateBack
        }
      }
      .do { step in
        self.steps.accept(step)
      }
      .mapToVoid()

    return Output(
      taskTextSaveButtonIsHidden: taskTextSaveButtonIsHidden,
      taskDescriptionSaveButtonIsHidden: taskDescriptionSaveButtonIsHidden,
      kindSections: kindSections,
      kindOpenSettings: kindOpenSettings,
      expectedDateTime: expectedDateTime,
      expectedDatePickerOpen: expectedDatePickerOpen,
      expectedDatePickerClose: expectedDatePickerClose,
      expectedDatePickerScrollToToday: expectedDatePickerScrollToToday,
      expectedTimePickerOpen: expectedTimePickerOpen,
      expectedTimePickerClose: expectedTimePickerClose,
      expectedTimePickerScrollToEndOfDay: expectedTimePickerScrollToEndOfDay,
      bottomButtonsMode: bottomButtonsMode,
      taskSave: taskSave,
      close: close
    )
  }
}
