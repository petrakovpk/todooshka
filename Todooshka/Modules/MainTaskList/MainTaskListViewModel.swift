//
//  MainTaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.04.2022.
//

import CoreData
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class MainTaskListViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  public let swipeDeleteButtonClickTrigger = PublishRelay<IndexPath>()
  public let swipeIdeaButtonClickTrigger = PublishRelay<IndexPath>()
  
  public let calendarSelectedDate = BehaviorRelay<Date>(value: Date())
  public let calendarVisibleMonth = BehaviorRelay<Date>(value: Date())
  
  private let calendarStartMonth = BehaviorRelay<Date>(value: Date().adding(.month, value: -4))
  private let calendarEndMonth = BehaviorRelay<Date>(value: Date().adding(.month, value: 3))

  private let services: AppServices
  private let disposeBag = DisposeBag()

  struct Input {
    // overdued
    let overduedButtonClickTrigger: Driver<Void>
    // idea
    let ideaButtonClickTrigger: Driver<Void>
    // task list
    let taskSelected: Driver<IndexPath>
    // calendar
    let calendarMonthLabelClickTrigger: Driver<Void>
    let calendarButtonClickTrigger: Driver<Void>
    // alert
    let alertDeleteButtonClick: Driver<Void>
    let alertCancelButtonClick: Driver<Void>
  }

  struct Output {
    // overdued
    let overduredTaskListOpen: Driver<Void>
    // idea
    let ideaTaskListOpen: Driver<Void>
    // task sections
    let taskListSections: Driver<[TaskListSection]>
    let taskListOpenTask: Driver<AppStep>
    // calendar
    let calendarMonthLabelText: Driver<String>
    let calendarSections: Driver<[CalendarSection]>
    let calendarIsHidden: Driver<Bool>
    let calendarScrollToDate: Driver<Date>
    let calendarButtonImage: Driver<UIImage>
    // alert
    let deleteAlertIsHidden: Driver<Bool>
    // save task
    let saveTask: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let kinds = services.currentUserService.kinds
    let tasks = services.currentUserService.tasks
    let swipeIdeaButtonClickTrigger = swipeIdeaButtonClickTrigger.asDriverOnErrorJustComplete()
    let swipeDeleteButtonClickTrigger = swipeDeleteButtonClickTrigger.asDriverOnErrorJustComplete()
    let calendarVisibleMonth = calendarVisibleMonth.asDriver()
    let calendarSelectedDate = calendarSelectedDate.asDriver()
    let calendarStartMonth = calendarStartMonth.asDriver()
    let calendarEndMonth = calendarEndMonth.asDriver()
    let errorTracker = ErrorTracker()
    
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
          task.planned.startOfDay == calendarSelectedDate.startOfDay &&
          task.planned.startOfDay >= Date().startOfDay
        }
        .map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kind: kinds.first { $0.uuid == task.kindUUID },
            mode: calendarSelectedDate.isInToday ? .blueLine : .empty
          )
        }
    }
    
    let plannedInDayItems = Driver
      .combineLatest(kinds, tasks, calendarSelectedDate) { kinds, tasks, calendarSelectedDate -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          task.status == .inProgress &&
          task.planned >= calendarSelectedDate.startOfDay &&
          task.planned.roundToTheBottomMinute < calendarSelectedDate.endOfDay.roundToTheBottomMinute &&
          task.planned.startOfDay >= Date().startOfDay
        }
        .map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kind: kinds.first { $0.uuid == task.kindUUID },
            mode: calendarSelectedDate.isInToday ? .redLineAndTime : .time
          )
        }
    }
    
    let plannedTaskListSections = Driver
      .zip(plannedAllDayItems, plannedInDayItems) { plannedAllDayItems, plannedInDayItems -> [TaskListSection] in
        [
          TaskListSection(header: "В течении дня:", items: plannedAllDayItems),
          TaskListSection(header: "Ко времени", items: plannedInDayItems)
        ]
      }
    
    let taskListSections = Driver
      .zip(completedTaskListSection, plannedTaskListSections) { completedTaskListSection, plannedTaskListSections -> [TaskListSection] in
        plannedTaskListSections + [completedTaskListSection]
      }
      .map { sections -> [TaskListSection] in
        sections.filter { section -> Bool in
          !section.items.isEmpty
        }
      }
    
    let overduredTaskListOpen = input.overduedButtonClickTrigger
      .map { _ in AppStep.overduedTaskListIsRequired }
      .do { step in self.steps.accept(step) }
      .mapToVoid()
    
    let ideaTaskListOpen = input.ideaButtonClickTrigger
      .map { _ in AppStep.ideaTaskListIsRequired }
      .do { step in self.steps.accept(step) }
      .mapToVoid()
    
    let taskListOpenTask = input.taskSelected
      .withLatestFrom(taskListSections) { indexPath, sections -> TaskListSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
      .map { item -> AppStep in
        AppStep.openTaskIsRequired(task: item.task, taskListMode: .main)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    // MARK: - Calendar
    let calendarMonthLabelText = calendarVisibleMonth
      .map { date -> String in
        "\(DateFormatter.month.string(from: date).capitalized) \(date.year.string)"
      }
    
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
    
    let calendarScrollToToday = input.calendarMonthLabelClickTrigger
      .map { Date() }
    
    let calendarIsHidden = input.calendarButtonClickTrigger
      .scan(true) { isHiden, _ -> Bool in
        !isHiden
      }
    
    let calendarButtonImage = calendarIsHidden
      .compactMap { isHidden -> UIImage? in
        isHidden ?
        Icon.calendar.image.template :
        UIImage(
          systemName: "xmark",
          withConfiguration: UIImage.SymbolConfiguration(
            pointSize: 14,
            weight: .light,
            scale: .medium))?.template
      }
    
    let swipeDeleteButtonItem = swipeDeleteButtonClickTrigger
      .withLatestFrom(taskListSections) { indexPath, sections -> TaskListSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let swipeIdeaButtonItem = swipeIdeaButtonClickTrigger
      .withLatestFrom(taskListSections) { indexPath, sections -> TaskListSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let showDeleteAlert = swipeDeleteButtonItem.mapToVoid()
    
    let hideDeleteAlert = Driver
      .of(input.alertDeleteButtonClick, input.alertCancelButtonClick)
      .merge()
    
    let deleteAlertIsHidden = Driver.of(
      showDeleteAlert.map { _ in false },
      hideDeleteAlert.map { _ in true }
    )
      .merge()
    
    let taskChangeStatusToDeleted = input.alertDeleteButtonClick
      .withLatestFrom(swipeDeleteButtonItem)
      .map { item -> Task in
        var task = item.task
        task.status = .deleted
        return task
      }
    
    let taskChangeStatusToIdea = swipeIdeaButtonItem
      .map { item -> Task in
        var task = item.task
        task.status = .idea
        return task
      }
    
    let saveTask = Driver
      .of(taskChangeStatusToDeleted, taskChangeStatusToIdea)
      .merge()
      .flatMapLatest { task -> Driver<Void> in
        task.updateToStorage()
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }
                
    return Output(
      // overdued
      overduredTaskListOpen: overduredTaskListOpen,
      // idea
      ideaTaskListOpen: ideaTaskListOpen,
      // task list
      taskListSections: taskListSections,
      taskListOpenTask: taskListOpenTask,
      // calendar:
      calendarMonthLabelText: calendarMonthLabelText,
      calendarSections: calendarSections,
      calendarIsHidden: calendarIsHidden,
      calendarScrollToDate: calendarScrollToToday,
      calendarButtonImage: calendarButtonImage,
      // alert
      deleteAlertIsHidden: deleteAlertIsHidden,
      // save task
      saveTask: saveTask
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
