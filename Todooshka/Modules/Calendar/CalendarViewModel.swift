//
//  MainCalendarViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.01.2023.
//

import CoreData
import RxFlow
import RxSwift
import RxCocoa

enum CalendarMode {
  case short
  case long
}

class CalendarViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let selectedDate = BehaviorRelay<Date>(value: Date())
  public let displayDate = BehaviorRelay<Date>(value: Date())
  public let swipeDeleteButtonClickTrigger = PublishRelay<IndexPath>()
  public let swipeIdeaButtonClickTrigger = PublishRelay<IndexPath>()
  
  private let services: AppServices
  private let minMonthIndex = BehaviorRelay<Int>(value: -2)
  private let maxMonthIndex = BehaviorRelay<Int>(value: 2)

  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  private var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }
  private var calendarMode: CalendarMode = .long
  
  struct Input {
    let monthLabelClickTrigger: Driver<Void>
    let changeCalendarModeButtonClickTrigger: Driver<Void>
    let shopButtonClickTrigger: Driver<Void>
    let settingsButtonClickTrigger: Driver<Void>
    let scrollToPreviousPeriodButtonClickTrigger: Driver<Void>
    let scrollToNextPeriodButtonClickTrigger: Driver<Void>
    let addTaskButtonClickTrigger: Driver<Void>
    let calendarTaskListSelection: Driver<IndexPath>
  }

  struct Output {
//    let calendarMode: Driver<CalendarMode>
//    let openShop: Driver<Void>
//    let openSettings: Driver<Void>
//    let calendarAddMonths: Driver<Void>
//    let calendarDataSource: Driver<Dictionary<Date, CalendarItem>>
//    let scrollToDate: Driver<Date>
//    let monthButtonTitle: Driver<String>
//    let addTask: Driver<Void>
//    let calendarTaskListLabel: Driver<String>
//    let calendarTaskListDataSource: Driver<[TaskListSection]>
//    let openCalendarTask: Driver<Task>
//    let changeTaskStatusToIdea: Driver<Result<Void, Error>>
//    let changeTaskStatusToDeleted: Driver<Result<Void, Error>>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
//    // MARK: - INIT
//    let swipeIdeaButtonClickTrigger = swipeIdeaButtonClickTrigger.asDriverOnErrorJustComplete()
//    let swipeDeleteButtonClickTrigger = swipeDeleteButtonClickTrigger.asDriverOnErrorJustComplete()
//    let minMonthIndex = minMonthIndex.asDriver()
//    let maxMonthIndex = maxMonthIndex.asDriver()
//    let displayDate = displayDate.asDriver()
//    let tasks = services.dataService.tasks
//    let kindsOfTask = services.dataService.kindsOfTask.asDriver()
//    let selectedDate = selectedDate.asDriver()
//      .do { date in
//        self.services.dataService.selectedDate.accept(date)
//      }
//
//    let openShop = input.shopButtonClickTrigger
//      .do { _ in self.steps.accept(AppStep.shopIsRequired) }
//
//    let openSettings = input.settingsButtonClickTrigger
//      .do { _ in self.steps.accept(AppStep.settingsIsRequired) }
//
//    // MARK: - CALENDAR
//    let calendarMode = input.changeCalendarModeButtonClickTrigger
//      .map { _ -> CalendarMode in
//        switch self.calendarMode {
//        case .short:
//          return .long
//        case .long:
//          return .short
//        }
//      }
//      .do { calendarMode in
//        self.calendarMode = calendarMode
//      }
//      .startWith(self.calendarMode)
//
//    // MARK: - DATASOURCE
//    let calendarAddPreviousMonth = displayDate
//      .withLatestFrom(minMonthIndex) { displayDate, minMonthIndex in
//        if displayDate.months(from: Date()) < (minMonthIndex + 2) {
//          self.minMonthIndex.accept(minMonthIndex - 1)
//        }
//      }
//
//    let calendarAddNextMonth = displayDate
//      .withLatestFrom(maxMonthIndex) { displayDate, maxMonthIndex in
//        if displayDate.months(from: Date()) >= (maxMonthIndex - 1) {
//          self.maxMonthIndex.accept(maxMonthIndex + 1)
//        }
//      }
//
//    let calendarAddMonths = Driver
//      .of(calendarAddPreviousMonth, calendarAddNextMonth)
//      .merge()
//
//    let calendarDataSource = Driver.combineLatest(tasks, minMonthIndex, maxMonthIndex, selectedDate)
//    { tasks, minMonthIndex, maxMonthIndex, selectedDate -> Dictionary<Date, CalendarItem> in
//      (minMonthIndex ... maxMonthIndex)
//        .map { monthIndex -> Date in
//          Date().adding(.month, value: monthIndex).startOfMonth
//        }
//        .flatMap { startOfMonth -> [CalendarItem] in
//          Calendar.current
//            .numberOfDaysInMonth(for: startOfMonth)
//            .countableRange
//            .compactMap { dayIndex -> Date in
//              startOfMonth.adding(.day, value: dayIndex)
//            }
//            .map { date -> CalendarItem in
//              CalendarItem(
//                date: date,
//                isSelected: selectedDate == date,
//                completedTasksCount:
//                  tasks
//                  .filter { task -> Bool in
//                    (task.status == .completed || task.status == .published) &&
//                    (task.completed ?? Date()).startOfDay == date.startOfDay
//                  }.count,
//                plannedTasksCount:
//                  tasks
//                  .filter { task -> Bool in
//                    task.status == .inProgress &&
//                    task.planned.startOfDay == date.startOfDay
//                  }.count
//              )
//            }
//        }
//        .reduce(into: [Date: CalendarItem]()) { partialResult, item in
//          partialResult[item.date] = item
//        }
//    }
//
//    let scrollToCurrentDate = input.monthLabelClickTrigger
//      .map { Date() }
//
//    let scrollToPreviousPeriod = input.scrollToPreviousPeriodButtonClickTrigger
//      .withLatestFrom(displayDate)
//      .map { displayDate -> Date in
//        switch self.calendarMode {
//        case .short:
//          return displayDate.adding(.weekOfMonth, value: -1)
//        case .long:
//          return displayDate.adding(.month, value: -1)
//        }
//      }
//
//    let scrollToNextPeriod = input.scrollToNextPeriodButtonClickTrigger
//      .withLatestFrom(displayDate)
//      .map { displayDate -> Date in
//        switch self.calendarMode {
//        case .short:
//          return displayDate.adding(.weekOfMonth, value: 1)
//        case .long:
//          return displayDate.adding(.month, value: 1)
//        }
//      }
//
//    let scrollToDate = Driver
//      .of(scrollToCurrentDate, scrollToPreviousPeriod, scrollToNextPeriod)
//      .merge()
//      .startWith(Date())
//
//    let monthButtonTitle = displayDate
//      .map { date -> String in
//        DateFormatter.monthAndYear.string(from: date).capitalized + " " + date.year.string
//      }
//
//    let addTask = input.addTaskButtonClickTrigger
//      .withLatestFrom(selectedDate)
//      .map { selectedDate -> Void in
//        self.steps.accept(
//          AppStep.createTaskIsRequired(
//            task: Task(
//              uuid: UUID().uuidString,
//              status: .inProgress,
//              planned: selectedDate.endOfDay,
//              completed: selectedDate.startOfDay <= Date().startOfDay ? selectedDate : nil),
//            isModal: false
//          ))
//      }
//
//    let calendarTaskListLabel = selectedDate
//      .map { selectedDate -> String in
//        selectedDate.string(withFormat: "dd MMMM yyyy")
//      }
//
//    // MARK: - DATASOURCE COMPLETED
//    let completedItems = Driver
//      .combineLatest(selectedDate, tasks, kindsOfTask) { selectedDate, tasks, kindsOfTask -> [TaskListSectionItem] in
//        tasks
//          .filter { task -> Bool in
//            (task.status == .completed || task.status == .published) &&
//            (task.completed ?? Date()).startOfDay >= selectedDate.startOfDay &&
//            (task.completed ?? Date()).endOfDay <= selectedDate.endOfDay
//          }
//          .sorted { prevTask, nextTask -> Bool in
//            prevTask.completed ?? Date() < nextTask.completed ?? Date()
//          }
//          .map { task -> TaskListSectionItem in
//            TaskListSectionItem(
//              task: task,
//              kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
//            )
//          }
//      }
//
//    let publishedSection = completedItems
//      .map { items -> TaskListSection in
//        TaskListSection(
//          header: "Опубликовано:",
//          mode: .likes,
//          items: items
//            .filter { item -> Bool in
//              item.task.status == .published
//            }
//        )
//      }
//
//    let completedSection = completedItems
//      .map { items -> TaskListSection in
//        TaskListSection(
//          header: "Выполнено:",
//          mode: .empty,
//          items: items
//            .filter { item -> Bool in
//              item.task.status == .completed
//            }
//        )
//      }
//
//    // MARK: - DATASOURCE PLANNED
//    let plannedListItems = Driver<[TaskListSectionItem]>
//      .combineLatest(selectedDate, tasks, kindsOfTask) { selectedDate, tasks, kindsOfTask -> [TaskListSectionItem] in
//        tasks
//          .filter { task -> Bool in
//            task.status == .inProgress &&
//            task.planned.startOfDay >= selectedDate.startOfDay &&
//            task.planned.endOfDay <= selectedDate.endOfDay
//          }
//          .map { task -> TaskListSectionItem in
//            TaskListSectionItem(
//              task: task,
//              kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
//            )
//          }
//          .sorted { prevItem, nextItem -> Bool in
//            prevItem.task.created < nextItem.task.created
//          }
//      }
//
//    let plannedToTimeSection = plannedListItems
//      .withLatestFrom(selectedDate) { items, selectedDate -> TaskListSection in
//        TaskListSection(
//          header: "Запланировано ко времени:",
//          mode: .time,
//          items: items
//            .filter { item -> Bool in
//              item.task.planned.roundToTheBottomMinute != selectedDate.endOfDay.roundToTheBottomMinute
//            })
//      }
//
//    let plannedAllDaySection = plannedListItems
//      .withLatestFrom(selectedDate) { items, selectedDate -> TaskListSection in
//        TaskListSection(
//          header: "Запланировано в течении дня:",
//          mode: .empty,
//          items: items
//            .filter { item -> Bool in
//              item.task.planned.roundToTheBottomMinute == selectedDate.endOfDay.roundToTheBottomMinute
//            })
//      }
//
//    // MARK: - DATASOURCE
//    let calendarTaskListDataSource = Driver
//      .zip(publishedSection, completedSection, plannedToTimeSection, plannedAllDaySection) { publishedSection, completedSection, plannedToTimeSection, plannedAllDaySection -> [TaskListSection] in
//        [publishedSection, completedSection, plannedToTimeSection, plannedAllDaySection]
//          .filter { !$0.items.isEmpty }
//      }
//
//    let openCalendarTask = input.calendarTaskListSelection
//      .withLatestFrom(calendarTaskListDataSource) { indexPath, dataSource -> Task in
//        dataSource[indexPath.section].items[indexPath.item].task
//      }
//      .do { task in
//        self.steps.accept(AppStep.showTaskIsRequired(task: task))
//      }
//
//    let changeTaskStatusToIdea = swipeIdeaButtonClickTrigger
//      .withLatestFrom(calendarTaskListDataSource) { indexPath, dataSource -> Task in
//        dataSource[indexPath.section].items[indexPath.item].task
//      }
//      .change(status: .idea)
//      .asObservable()
//      .flatMapLatest { self.managedContext.rx.update($0) }
//      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
//
//    let changeTaskStatusToDeleted = swipeDeleteButtonClickTrigger
//      .withLatestFrom(calendarTaskListDataSource) { indexPath, dataSource -> Task in
//        dataSource[indexPath.section].items[indexPath.item].task
//      }
//      .change(status: .deleted)
//      .asObservable()
//      .flatMapLatest { self.managedContext.rx.update($0) }
//      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
    

    return Output(
//      calendarMode: calendarMode,
//      openShop: openShop,
//      openSettings: openSettings,
//      calendarAddMonths: calendarAddMonths,
//      calendarDataSource: calendarDataSource,
//      scrollToDate: scrollToDate,
//      monthButtonTitle: monthButtonTitle,
//      addTask: addTask,
//      calendarTaskListLabel: calendarTaskListLabel,
//      calendarTaskListDataSource: calendarTaskListDataSource,
//      openCalendarTask: openCalendarTask,
//      changeTaskStatusToIdea: changeTaskStatusToIdea,
//      changeTaskStatusToDeleted: changeTaskStatusToDeleted
    )
  }

}

