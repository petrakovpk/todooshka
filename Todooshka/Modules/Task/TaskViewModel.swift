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
    let kinds = services.currentUserService.currentUserKinds
    
    let taskTextSaveButtonIsHidden = Driver
      .combineLatest(input.taskTextField, task) { text, task -> Bool in
        text == task.text
      }
    
    let taskDescriptionSaveButtonIsHidden = Driver
      .combineLatest(input.taskDescriptionTextView, task) { description, task -> Bool in
        task.description == description
      }
    
    let taskTextChange = input.taskTextSaveButtonClickTrigger
      .withLatestFrom(input.taskTextField)
      .withLatestFrom(task) { text, task -> Task in
        var task = task
        task.text = text
        return task
      }
    
    let taskDescriptionChange = input.taskDescriptionSaveButtonClickTrigger
      .withLatestFrom(input.taskDescriptionTextView)
      .withLatestFrom(task) { description, task -> Task in
        var task = task
        task.description = description
        return task
      }

    let kindSections = Driver.combineLatest(task, kinds) { task, kinds -> KindSection in
      KindSection(
        header: "",
        items: kinds.map { kind -> KindSectionItem in
          KindSectionItem(kind: kind, isSelected: kind.uuid == task.kindUUID)
        })
    }
      .map { [$0] }
    
    let taskKindChange = input.kindOfTaskSelection
      .withLatestFrom(kindSections) { indexPath, sections -> KindSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
      .map { item -> Kind in item.kind }
      .withLatestFrom(task) { kind, task -> Task in
        var task = task
        task.kindUUID = kind.uuid
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
    
    let taskSave = Driver.of(
      taskTextChange,
      taskDescriptionChange,
      taskKindChange,
      taskExpectedDateChange,
      taskExpectedTimeChange,
      taskDraftStatusChange
    )
      .merge()
      .do { task in
        self.task.accept(task)
      }
      .asObservable()
      .flatMapLatest { task -> Observable<Void> in
        return task.updateToStorage()
      }
      .asDriver(onErrorJustReturn: ())
    
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
      input.expectedTimePickerOkButtonClickTrigger )
      .merge()
    
    let bottomButtonsMode = task
      .map { task -> BottomButtonsMode in
        switch task.status {
        case .draft:
          return .create
        default:
          return .complete
        }
      }
    
    let close = Driver.of(input.createButtonClickTrigger, input.backButtonClickTrigger)
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
