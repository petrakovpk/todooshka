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

class CalendarViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  public let calendarSelectedDate = BehaviorRelay<Date>(value: Date())
  public let calendarVisibleMonth = BehaviorRelay<Date>(value: Date())
  
  public let swipeDeleteButtonClickTrigger = PublishRelay<IndexPath>()
  public let swipeIdeaButtonClickTrigger = PublishRelay<IndexPath>()
  
  private let calendarStartMonth = BehaviorRelay<Date>(value: Date().adding(.month, value: -4))
  private let calendarEndMonth = BehaviorRelay<Date>(value: Date().adding(.month, value: 3))

  private let services: AppServices
  
  struct Input {
    // flow
    let shopButtonClickTrigger: Driver<Void>
    let settingsButtonClickTrigger: Driver<Void>
    // calendar
    let calendarHeaderLabelClickTrigger: Driver<Void>
    let calendarScrollToNextMonthButtonClickTrigger: Driver<Void>
    let calendarScrollToPreviousMonthButtonClickTrigger: Driver<Void>
    // all tasks button
    let allTasksButtonClickTrigger: Driver<Void>
    // task list
    let taskSelected: Driver<IndexPath>
  }

  struct Output {
    // flow
    let openShop: Driver<AppStep>
    let openSettings: Driver<AppStep>
    // calendar
    let calendarHeaderText: Driver<String>
    let calendarScrollToDate: Driver<Date>
    let calendarSections: Driver<[CalendarSection]>
    let calendarAddMonths: Driver<Void>
    // let
    let openDayTaskList: Driver<AppStep>
    // task list
    let taskListLabelText: Driver<String>
    let taskListSections: Driver<[TaskListSection]>
    let taskListOpenTask: Driver<AppStep>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let calendarVisibleMonth = calendarVisibleMonth.asDriver()
    let calendarSelectedDate = calendarSelectedDate.asDriver()
    let calendarStartMonth = calendarStartMonth.asDriver()
    let calendarEndMonth = calendarEndMonth.asDriver()
    
    let tasks = services.currentUserService.tasks
    let kinds = services.currentUserService.kinds
    
    let openShop = input.shopButtonClickTrigger
      .map { AppStep.shopIsRequired }
      .do { step in
        self.steps.accept(step)
      }
    
    let openSettings = input.settingsButtonClickTrigger
      .map { AppStep.settingsIsRequired }
      .do { step in
        self.steps.accept(step)
      }
    
    let calendarHeaderText = calendarVisibleMonth
      .map { date -> String in
        "\(DateFormatter.month.string(from: date).capitalized) \(date.year.string)"
      }
      .asDriver(onErrorJustReturn: "")
    
    let calendarScrollToToday = input.calendarHeaderLabelClickTrigger
      .map { Date() }

    let calendarScrollToNextMonth = input.calendarScrollToNextMonthButtonClickTrigger
      .withLatestFrom(calendarVisibleMonth)
      .map { date -> Date in
        date.adding(.month, value: 1)
      }
    
    let calendarScrollToPreviousMonth = input.calendarScrollToPreviousMonthButtonClickTrigger
      .withLatestFrom(calendarVisibleMonth)
      .map { date -> Date in
        date.adding(.month, value: -1)
      }
    
    let calendarScrollToDate = Driver
      .of(calendarScrollToToday, calendarScrollToNextMonth, calendarScrollToPreviousMonth)
      .merge()
    
    let calendarSections = Driver
      .combineLatest(tasks, calendarStartMonth, calendarEndMonth, calendarSelectedDate) { [self] tasks, calendarStartMonth, calendarEndMonth, calendarSelectedDate -> [CalendarSection] in
        getAllMonthsBetween(
          calendarStartMonth: calendarStartMonth,
          calendarEndMonth: calendarEndMonth)
          .map { date -> CalendarSection in
            CalendarSection(
              month: date,
              items: getAllDaysOfMonth(for: date).map { date -> CalendarItem in
                CalendarItem(
                  date: date,
                  isSelected: calendarSelectedDate.startOfDay == date.startOfDay,
                  completedTasksCount: tasks
                    .filter { task -> Bool in
                      (task.status == .completed || task.status == .published) &&
                      (task.completed ?? Date()).startOfDay == date.startOfDay
                    }.count,
                  plannedTasksCount: tasks
                    .filter { task -> Bool in
                      task.status == .inProgress &&
                      task.planned.startOfDay == date.startOfDay
                    }.count
                )
              }
            )
          }
      }
    
    let calendarAddPreviousMonths = calendarVisibleMonth
      .withLatestFrom(calendarStartMonth) { calendarVisibleMonth, calendarStartMonth in
        if self.getAllMonthsBetween(
          calendarStartMonth: calendarStartMonth,
          calendarEndMonth: calendarVisibleMonth).count < 2 {
          self.calendarStartMonth.accept(self.calendarStartMonth.value.adding(.month, value: -5))
        }
      }
    
    let calendarAddNextMonths = calendarVisibleMonth
      .withLatestFrom(calendarEndMonth) { calendarVisibleMonth, calendarEndMonth in
        if self.getAllMonthsBetween(
          calendarStartMonth: calendarVisibleMonth,
          calendarEndMonth: calendarEndMonth).count < 2 {
          self.calendarStartMonth.accept(self.calendarEndMonth.value.adding(.month, value: 5))
        }
      }
    
    let calendarAddMonths = Driver
      .of(calendarAddPreviousMonths, calendarAddNextMonths)
      .merge()

    let taskListLabelText = calendarSelectedDate
      .map { calendarSelectedDate -> String in
        calendarSelectedDate.string(withFormat: "dd MMMM yyyy")
      }
    
    // MARK: - Datasource - Completed
    let completedTaskListItems = Driver
      .combineLatest(kinds, tasks, calendarSelectedDate) { kinds, tasks, calendarSelectedDate -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          task.status == .completed &&
          task.completed?.startOfDay == calendarSelectedDate.startOfDay
        }
        .map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kind: kinds.first { $0.uuid == task.kindUUID },
            mode: .empty)
        }
      }
    
    let completedTaskListSection = completedTaskListItems
      .map { items -> TaskListSection in
        TaskListSection(header: "Выполнено:", items: items)
      }
    
    // MARK: - Datasource - Planned
    let plannedAllDayItems = Driver
      .combineLatest(kinds, tasks, calendarSelectedDate) { kinds, tasks, calendarSelectedDate -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          task.status == .inProgress &&
          task.planned.roundToTheBottomMinute == calendarSelectedDate.endOfDay.roundToTheBottomMinute &&
          task.planned.startOfDay == calendarSelectedDate.startOfDay
        }
        .map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kind: kinds.first { $0.uuid == task.kindUUID },
            mode: .empty
          )
        }
    }
    
    let plannedInDayItems = Driver
      .combineLatest(kinds, tasks, calendarSelectedDate) { kinds, tasks, calendarSelectedDate -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          task.status == .inProgress &&
          task.planned >= calendarSelectedDate.startOfDay &&
          task.planned.roundToTheBottomMinute < calendarSelectedDate.endOfDay.roundToTheBottomMinute
        }
        .map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kind: kinds.first { $0.uuid == task.kindUUID },
            mode: .time
          )
        }
    }
    
    let plannedTaskListSections = Driver
      .combineLatest(plannedAllDayItems, plannedInDayItems) { plannedAllDayItems, plannedInDayItems -> [TaskListSection] in
        [
          TaskListSection(header: "В течении дня:", items: plannedAllDayItems),
          TaskListSection(header: "Ко времени", items: plannedInDayItems)
        ]
      }
    
    // MARK: - Datasource - Task List Sections
    let taskListSections = Driver
      .combineLatest(completedTaskListSection, plannedTaskListSections) { completedTaskListSection, plannedTaskListSections -> [TaskListSection] in
        [completedTaskListSection] + plannedTaskListSections
      }
      .map { sections -> [TaskListSection] in
        sections.filter { section -> Bool in
          !section.items.isEmpty
        }
      }
    
    let taskListOpenTask = input.taskSelected
      .withLatestFrom(taskListSections) { indexPath, sections -> Task in
        sections[indexPath.section].items[indexPath.item].task
      }
      .map { task -> AppStep in
        AppStep.openTaskIsRequired(task: task, taskListMode: .calendar)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let openDayTaskList = input.allTasksButtonClickTrigger
      .withLatestFrom(calendarSelectedDate)
      .map { selectedDate -> AppStep in
        AppStep.dayTaskListIsRequired(date: selectedDate)
      }
      .do { step in
        self.steps.accept(step)
      }

    return Output(
      // flow
      openShop: openShop,
      openSettings: openSettings,
      // calendar
      calendarHeaderText: calendarHeaderText,
      calendarScrollToDate: calendarScrollToDate,
      calendarSections: calendarSections,
      calendarAddMonths: calendarAddMonths,
      // open
      openDayTaskList: openDayTaskList,
      // task list
      taskListLabelText: taskListLabelText,
      taskListSections: taskListSections,
      taskListOpenTask: taskListOpenTask
    )
  }
  
  func getAllMonthsBetween(calendarStartMonth: Date, calendarEndMonth: Date) -> [Date] {
      var months: [Date] = []
      let calendar = Calendar.current
      
      var currentDate = calendarStartMonth
      
      while currentDate <= calendarEndMonth {
          months.append(currentDate)
          if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
              currentDate = nextMonth
          } else {
              break
          }
      }
      
      return months
  }
  
  func getAllDaysOfMonth(for date: Date) -> [Date] {
      var days: [Date] = []
      let calendar = Calendar.current
      
      // Найти начало месяца и количество дней в месяце
      if let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start,
         let range = calendar.range(of: .day, in: .month, for: date) {
          
          for dayOffset in range {
              if let day = calendar.date(byAdding: .day, value: dayOffset - 1, to: startOfMonth) {
                  days.append(day)
              }
          }
      }
      
      return days
  }

}

