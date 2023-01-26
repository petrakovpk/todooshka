//
//  CalendarViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 19.01.2023.
//

import RxFlow
import RxSwift
import RxCocoa
import CoreData

class CalendarViewModel: Stepper {
  
  public let steps = PublishRelay<Step>()
  public let selectedDate = BehaviorRelay<Date>(value: Date())
  public let displayDate = BehaviorRelay<Date>(value: Date())
  public let changeStatusTrigger = PublishRelay<ChangeStatus>()
  
  private let services: AppServices
  private let minMonthIndex = BehaviorRelay<Int>(value: -2)
  private let maxMonthIndex = BehaviorRelay<Int>(value: 2)
  
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  private var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }
  
  private var isCalendarInShortMode = false
  
  struct Input {
    let monthLabelClickTrigger: Driver<Void>
    let changeCalendarModeButtonClickTrigger: Driver<Void>
    let scrollToPreviousPeriodButtonClickTrigger: Driver<Void>
    let scrollToNextPeriodButtonClickTrigger: Driver<Void>
    let addTaskButtonClickTrigger: Driver<Void>
    let calendarTaskListSelection: Driver<IndexPath>
  }

  struct Output {
    let isCalendarInShortMode: Driver<Bool>
    let calendarAddMonths: Driver<Void>
    let calendarDataSource: Driver<[CalendarSection]>
    let scrollToDate: Driver<Date>
    let monthButtonTitle: Driver<String>
    let addTask: Driver<Void>
    let calendarTaskListLabel: Driver<String>
    let calendarTaskListDataSource: Driver<[TaskListSection]>
    let openCalendarTask: Driver<Task>
    let changeCalendarTaskStatus: Driver<Result<Void, Error>>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    // MARK: - INIT
    let minMonthIndex = minMonthIndex.asDriver()
    let maxMonthIndex = maxMonthIndex.asDriver()
    let selectedDate = selectedDate.asDriver()
    let displayDate = displayDate.asDriver()
    let tasks = services.dataService.tasks
    let kindsOfTask = services.dataService.kindsOfTask.asDriver()
    
    // MARK: - CALENDAR
    let isCalendarInShortMode = input
      .changeCalendarModeButtonClickTrigger
      .map { _ -> Bool in
        return !self.isCalendarInShortMode
      }
      .startWith(false)
      .do { isCalendarInShortMode in
        self.isCalendarInShortMode = isCalendarInShortMode
      }
    
    // MARK: - DATASOURCE
    let calendarAddPreviousMonth = displayDate
      .withLatestFrom(minMonthIndex) { displayDate, minMonthIndex in
        if displayDate.months(from: Date()) < (minMonthIndex + 2) {
          self.minMonthIndex.accept(minMonthIndex - 1)
        }
      }
    
    let calendarAddNextMonth = displayDate
      .withLatestFrom(maxMonthIndex) { displayDate, maxMonthIndex in
        if displayDate.months(from: Date()) >= (maxMonthIndex - 1) {
          self.maxMonthIndex.accept(maxMonthIndex + 1)
        }
      }
    
    let calendarAddMonths = Driver
      .of(calendarAddPreviousMonth, calendarAddNextMonth)
      .merge()
    
    let calendarDataSource = Driver.combineLatest(tasks, minMonthIndex, maxMonthIndex)
    { tasks, minMonthIndex, maxMonthIndex -> [CalendarSection] in
      (minMonthIndex ... maxMonthIndex)
        .map { monthIndex -> Date in
          Date().adding(.month, value: monthIndex).startOfMonth
        }
        .map { startOfMonth -> CalendarSection in
          CalendarSection(
            year: startOfMonth.year,
            month: startOfMonth.month,
            items:
              Calendar.current
              .numberOfDaysInMonth(for: startOfMonth)
              .countableRange
              .compactMap { dayIndex -> Date in
                startOfMonth.adding(.day, value: dayIndex)
              }
              .map { date -> CalendarItem in
                CalendarItem(
                  date: date,
                  isSelected: false,
                  completedTasksCount:
                    tasks
                    .filter { task -> Bool in
                      guard let completed = task.completed else { return false }
                      return task.status == .completed
                      && completed.startOfDay == date.startOfDay
                    }.count,
                  plannedTasksCount:
                    tasks
                    .filter { task -> Bool in
                      task.status == .inProgress
                      && task.planned.startOfDay == date.startOfDay
                    }.count
                )
              }
          )
        }
    }
    
    let scrollToCurrentDate = input.monthLabelClickTrigger
      .map { Date() }
    
    let scrollToPreviousPeriod = input.scrollToPreviousPeriodButtonClickTrigger
      .withLatestFrom(displayDate)
      .withLatestFrom(isCalendarInShortMode) { displayDate, isCalendarInShortMode -> Date in
        displayDate.adding(isCalendarInShortMode ? .weekOfMonth : .month, value: -1)
      }
    
    let scrollToNextPeriod = input.scrollToNextPeriodButtonClickTrigger
      .withLatestFrom(displayDate)
      .withLatestFrom(isCalendarInShortMode) { displayDate, isCalendarInShortMode -> Date in
        displayDate.adding(isCalendarInShortMode ? .weekOfMonth : .month, value: 1)
      }
    
    let scrollToDate = Driver
      .of(scrollToCurrentDate, scrollToPreviousPeriod, scrollToNextPeriod)
      .merge()
      .startWith(Date())
    
    let monthButtonTitle = displayDate
      .map { date -> String in
        DateFormatter.monthAndYear.string(from: date).capitalized + " " + date.year.string
      }
    
    let addTask = input.addTaskButtonClickTrigger
      .withLatestFrom(selectedDate)
      .map { selectedDate -> Void in
        self.steps.accept(
          AppStep.createTaskIsRequired(
            task: Task(
              UID: UUID().uuidString,
              status:  selectedDate.startOfDay <= Date().startOfDay ? .completed : .inProgress,
              planned: selectedDate.endOfDay,
              completed: selectedDate.startOfDay <= Date().startOfDay ? selectedDate : nil),
            isModal: true
          ))
      }
    
    let calendarTaskListLabel = selectedDate
      .map { selectedDate -> String in
        selectedDate.string(withFormat: "dd MMMM yyyy")
      }
    
    // MARK: - DATASOURCE COMPLETED
    let completedListSections = Driver
      .combineLatest(selectedDate, tasks, kindsOfTask) { selectedDate, tasks, kindsOfTask -> [TaskListSectionItem] in
        tasks
          .filter { task -> Bool in
            guard let completed = task.completed else { return false }
            return task.status == .completed &&
            completed.startOfDay >= selectedDate.startOfDay &&
            completed.endOfDay <= selectedDate.endOfDay
          }
          .sorted { prevTask, nextTask -> Bool in
            guard
              let prevTaskCompleted = prevTask.completed,
              let nextTaskCompleted = nextTask.completed
            else { return false }
            return prevTaskCompleted < nextTaskCompleted
          }
          .map { task -> TaskListSectionItem in
            TaskListSectionItem(
              task: task,
              kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
            )
          }
      }
      .withLatestFrom(selectedDate) { items, selectedDate -> [TaskListSection] in
        [
          TaskListSection(
            header: "Выполнено:",
            mode: .empty,
            items: items
          )
        ]
      }
    
    // MARK: - DATASOURCE PLANNED
    let plannedListSections = Driver<[TaskListSectionItem]>
      .combineLatest(selectedDate, tasks, kindsOfTask) { selectedDate, tasks, kindsOfTask -> [TaskListSectionItem] in
        tasks
          .filter { task -> Bool in
            task.status == .inProgress &&
            task.planned.startOfDay >= selectedDate.startOfDay &&
            task.planned.endOfDay <= selectedDate.endOfDay
          }
          .map { task -> TaskListSectionItem in
            TaskListSectionItem(
              task: task,
              kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
            )
          }
          .sorted { prevItem, nextItem -> Bool in
            prevItem.task.created < nextItem.task.created
          }
      }
      .withLatestFrom(selectedDate) { items, selectedDate -> [TaskListSection] in
        [
          TaskListSection(
            header: "Запланировано ко времени:",
            mode: .time,
            items: items
              .filter { item -> Bool in
                item.task.planned.roundToTheBottomMinute != selectedDate.endOfDay.roundToTheBottomMinute
              }),
          TaskListSection(
            header: "Запланировано в течении дня:",
            mode: .empty,
            items: items
              .filter { item -> Bool in
                item.task.planned.roundToTheBottomMinute == selectedDate.endOfDay.roundToTheBottomMinute
              })
        ]
          
      }
    
    // MARK: - DATASOURCE
    let calendarTaskListDataSource = Driver
      .zip(completedListSections, plannedListSections) { completedListSections, plannedListSections -> [TaskListSection] in
        (completedListSections + plannedListSections).filter { section -> Bool in
          !section.items.isEmpty
        }
      }
    
    let openCalendarTask = input.calendarTaskListSelection
      .withLatestFrom(calendarTaskListDataSource) { indexPath, dataSource -> Task in
        dataSource[indexPath.section].items[indexPath.item].task
      }
      .do { task in
        self.steps.accept(AppStep.showTaskIsRequired(task: task))
      }
    
    let changeCalendarTaskStatus = changeStatusTrigger
      .withLatestFrom(calendarTaskListDataSource) { changeStatus, dataSource -> Task in
        let indexPath = changeStatus.indexPath
        var task = dataSource[indexPath.section].items[indexPath.item].task
        task.status = changeStatus.status
        task.completed = changeStatus.completed
        return task
      }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
    
    return Output(
      isCalendarInShortMode: isCalendarInShortMode,
      calendarAddMonths: calendarAddMonths,
      calendarDataSource: calendarDataSource,
      scrollToDate: scrollToDate,
      monthButtonTitle: monthButtonTitle,
      addTask: addTask,
      calendarTaskListLabel: calendarTaskListLabel,
      calendarTaskListDataSource: calendarTaskListDataSource,
      openCalendarTask: openCalendarTask,
      changeCalendarTaskStatus: changeCalendarTaskStatus
    )
  }

}

