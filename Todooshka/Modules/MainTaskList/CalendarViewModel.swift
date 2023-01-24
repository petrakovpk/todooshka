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

  private let services: AppServices
  private let minMonthIndex = BehaviorRelay<Int>(value: -1)
  private let maxMonthIndex = BehaviorRelay<Int>(value: 2)
  
  private var isCalendarInShortMode = false
  
  struct Input {
    let changeCalendarModeButtonClickTrigger: Driver<Void>
    let scrollToPreviousPeriodButtonClickTrigger: Driver<Void>
    let scrollToNextPeriodButtonClickTrigger: Driver<Void>
    let addTaskButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let isCalendarInShortMode: Driver<Bool>
    let dataSource: Driver<[CalendarSection]>
    let scrollToDate: Driver<Date>
    let monthButtonTitle: Driver<String>
    let addTask: Driver<Void>
    let calendarTaskListLabel: Driver<String>
    let calendarTaskListDataSource: Driver<[TaskListSection]>
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
      .do { isCalendarInShortMode in
        self.isCalendarInShortMode = isCalendarInShortMode
      }
    
    // MARK: - DATASOURCE
    let dataSource = Driver.combineLatest(minMonthIndex, maxMonthIndex) { minMonthIndex, maxMonthIndex -> [CalendarSection] in
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
              .map { dayIndex -> CalendarItem in
                CalendarItem(
                  date: startOfMonth.adding(.day, value: dayIndex),
                  isSelected: false,
                  completedTasksCount: 0,
                  plannedTasksCount: 0
                )
              }
          )
        }
    }
    
    let scrollToPreviousPeriod = input.scrollToPreviousPeriodButtonClickTrigger
      .withLatestFrom(displayDate)
      .map { displayDate -> Date in
        displayDate.adding(.month, value: -1)
      }
    
    let scrollToNextPeriod = input.scrollToNextPeriodButtonClickTrigger
      .withLatestFrom(displayDate)
      .map { displayDate -> Date in
        displayDate.adding(.month, value: 1)
      }
    
    let scrollToDate = Driver
      .of(scrollToPreviousPeriod, scrollToNextPeriod)
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
              status: .inProgress,
              planned: selectedDate),
            isModal: true
          ))
      }
    
    let calendarTaskListLabel = selectedDate
      .map { selectedDate -> String in
        if selectedDate.startOfDay <= Date().startOfDay {
          return selectedDate.string(withFormat: "dd MMMM yyyy") + " выполнено:"
        } else {
          return "На " + selectedDate.string(withFormat: "dd MMMM yyyy") + " запланировано:"
        }
      }
    
    // MARK: - DATASOURCE COMPLETED
    let completedListTasks = Driver
      .combineLatest(tasks, selectedDate) { tasks, selectedDate -> [Task] in
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
      }
  
    let completedListItems = Driver.combineLatest(completedListTasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
      tasks.map { task -> TaskListSectionItem in
        TaskListSectionItem(
          task: task,
          kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
        )
      }
    }
    
    let completedListSectionEmpty = completedListItems
      .map {
        [
          TaskListSection(
            header: "",
            mode: .empty,
            items: $0
          )
        ]
      }
    
    return Output(
      isCalendarInShortMode: isCalendarInShortMode,
      dataSource: dataSource,
      scrollToDate: scrollToDate,
      monthButtonTitle: monthButtonTitle,
      addTask: addTask,
      calendarTaskListLabel: calendarTaskListLabel,
      calendarTaskListDataSource: completedListSectionEmpty
    )
  }

}

