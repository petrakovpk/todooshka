//
//  TaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import CoreData
import Firebase
import RxCocoa
import RxFlow
import RxSwift
import UIKit

class TaskListViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let taskListMode: TaskListMode
  
  public let inProgressButtonClickTrigger = PublishRelay<IndexPath>()
  public let swipeDeleteButtonClickTrigger = PublishRelay<IndexPath>()
  public let swipeIdeaButtonClickTrigger = PublishRelay<IndexPath>()
  
  private let services: AppServices

  struct Input {
    // BACK
    let backButtonClickTrigger: Driver<Void>
    // ADD
    let addTaskButtonClickTrigger: Driver<Void>
    // REMOVE ALL
    let removeAllButtonClickTrigger: Driver<Void>
    // task list
    let taskSelected: Driver<IndexPath>
    // ALERT
    let alertDeleteButtonClick: Driver<Void>
    let alertCancelButtonClick: Driver<Void>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    // task list
    let taskListSections: Driver<[TaskListSection]>
    // alert
    let deleteAlertText: Driver<String>
    let deleteAlertIsHidden: Driver<Bool>
    // task
    let openTask: Driver<AppStep>
    let saveTask: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, taskListMode: TaskListMode) {
    self.services = services
    self.taskListMode = taskListMode
  }

  func transform(input: Input) -> Output {
    let tasks = services.currentUserService.tasks
    let kinds = services.currentUserService.kinds
    
    let swipeIdeaButtonClickTrigger = swipeIdeaButtonClickTrigger.asDriverOnErrorJustComplete()
    let swipeDeleteButtonClickTrigger = swipeDeleteButtonClickTrigger.asDriverOnErrorJustComplete()
    let inProgressButtonClickTrigger = inProgressButtonClickTrigger.asDriverOnErrorJustComplete()
    
    // MARK: - Add task
    let createTaskIsRequired = input.addTaskButtonClickTrigger
      .compactMap { _ -> Task? in
        switch self.taskListMode {
        case .idea:
          return Task(uuid: UUID(), status: .draft)
        case .day(let date):
          return Task(uuid: UUID(), status: .draft, planned: date)
        default:
          return nil
        }
      }

    // MARK: - TaskListSections - Overdued
    let overduedTaskListItems = Driver
      .combineLatest(kinds, tasks) { kinds, tasks -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          task.status == .inProgress &&
          task.planned.startOfDay < Date().startOfDay
        }
        .sorted { $0.planned < $1.planned }
        .map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kind: kinds.first { $0.uuid == task.kindUUID },
            mode: .repeatButton)
        }
      }
    
    let overduedTaskListSections = overduedTaskListItems
      .map { items -> TaskListSection in
        TaskListSection(header: "", items: items)
      }
    
    // MARK: - TaskListSections - Idea
    let ideaTaskListItems = Driver
      .combineLatest(kinds, tasks) { kinds, tasks -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          task.status == .idea
        }
        .map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kind: kinds.first { $0.uuid == task.kindUUID },
            mode: .repeatButton)
        }
      }
    
    let ideaTaskListSections = ideaTaskListItems
      .map { items -> TaskListSection in
        TaskListSection(header: "", items: items)
      }
    
    // MARK: - TaskListSections - Completed
    let completedTaskListItems = Driver
      .combineLatest(kinds, tasks) { kinds, tasks -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          guard case .day(let date) = self.taskListMode else { return false }
          return task.status == .completed &&
          task.completed?.startOfDay == date.startOfDay
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
    
    // MARK: - TaskListSections - Planned
    let plannedAllDayItems = Driver
      .combineLatest(kinds, tasks) { kinds, tasks -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          guard case .day(let date) = self.taskListMode else { return false }
          return task.status == .inProgress &&
          task.planned.roundToTheBottomMinute == date.endOfDay.roundToTheBottomMinute &&
          task.planned.startOfDay == date.startOfDay
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
      .combineLatest(kinds, tasks) { kinds, tasks -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          guard case .day(let date) = self.taskListMode else { return false }
          return task.status == .inProgress &&
          task.planned >= date.startOfDay &&
          task.planned.roundToTheBottomMinute < date.endOfDay.roundToTheBottomMinute
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
    
    // MARK: - TaskListSections - Deleted

    // MARK: - TaskListSections - All
    let taskListSections = Driver
      .combineLatest(overduedTaskListSections, ideaTaskListSections, completedTaskListSection, plannedTaskListSections)
    { overduedTaskListSections, ideaTaskListSections, completedTaskListSection, plannedTaskListSections -> [TaskListSection] in
        switch self.taskListMode {
        case .overdued:
          return [overduedTaskListSections]
        case .idea:
          return [ideaTaskListSections]
        case .day(_):
          return [completedTaskListSection] + plannedTaskListSections
        default:
          return []
        }
      }
      .map { sections -> [TaskListSection] in
        sections.filter { section -> Bool in
          !section.items.isEmpty
        }
      }
    
    // MARK: - Open task
    let openTaskIsRequired = input.taskSelected
      .withLatestFrom(taskListSections) { indexPath, sections -> Task in
        sections[indexPath.section].items[indexPath.item].task
      }
    
    let openTask = Driver.of(createTaskIsRequired, openTaskIsRequired)
      .merge()
      .map { task -> AppStep in
        AppStep.openTaskIsRequired(task: task, taskListMode: self.taskListMode)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    // MARK: - Change task
    let swipeDeleteItem = swipeDeleteButtonClickTrigger
      .withLatestFrom(taskListSections) { indexPath, sections -> TaskListSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let swipeIdeaItem = swipeIdeaButtonClickTrigger
      .withLatestFrom(taskListSections) { indexPath, sections -> TaskListSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let inProgressItem = inProgressButtonClickTrigger
      .withLatestFrom(taskListSections) { indexPath, sections -> TaskListSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let showDeleteAlert = swipeDeleteItem.mapToVoid()
    
    let hideDeleteAlert = Driver
      .of(input.alertDeleteButtonClick, input.alertCancelButtonClick)
      .merge()
    
    let deleteAlertIsHidden = Driver.of(
      showDeleteAlert.map { _ in false },
      hideDeleteAlert.map { _ in true }
    )
      .merge()
    
    let deleteAlertText = Driver.of(
      swipeDeleteItem.map { _ in "Удалить задачу?" },
      input.removeAllButtonClickTrigger.map { _ in "Удалить все задачи?" }
    )
      .merge()
    
    let taskChangeStatusToDeleted = input.alertDeleteButtonClick
      .withLatestFrom(swipeDeleteItem)
      .map { item -> Task in
        var task = item.task
        task.status = .deleted
        return task
      }
    
    let taskChangeStatusToIdea = swipeIdeaItem
      .map { item -> Task in
        var task = item.task
        task.status = .idea
        return task
      }
    
    let taskChangeStatusToInProgress = inProgressItem
      .map { item -> Task in
        var task = item.task
        task.status = .inProgress
        task.planned = Date().endOfDay
        return task
      }
    
    let saveTask = Driver
      .of(taskChangeStatusToDeleted, taskChangeStatusToIdea, taskChangeStatusToInProgress)
      .merge()
      .asObservable()
      .flatMapLatest { task -> Observable<Void> in
        return task.updateToStorage()
      }
      .asDriver(onErrorJustReturn: ())
    
//    let addTask = input.addTaskButtonClickTrigger
//      .withLatestFrom(emptyKind)
//      .compactMap { emptyKind -> Task? in
//        switch self.taskListMode {
//        case .idea:
//          return Task(uuid: UUID(), status: .idea, kindUUID: emptyKind.uuid)
//        case .day(let date):
//          return Task(uuid: UUID(), status: .inProgress, planned: date, kindUUID: emptyKind.uuid)
//        default:
//          return nil
//        }
//      }
//      .map { task -> AppStep in
//        AppStep.openTaskIsRequired(task: task, taskListMode: self.taskListMode)
//      }
//      .do { step in
//        self.steps.accept(step)
//      }
      
    
//    // MARK: - DELETED COMPLETED
//    let deletedListTasks = tasks
//      .map { tasks -> [Task] in
//        tasks.filter { task -> Bool in
//          guard
//            case .deleted = self.mode
//          else { return false }
//
//          return task.status == .deleted
//        }
//        .sorted { prevTask, nextTask -> Bool in
//          prevTask.created < nextTask.created
//        }
//      }
//
//    let deletedListItems = Driver.combineLatest(deletedListTasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
//      tasks.map { task -> TaskListSectionItem in
//        TaskListSectionItem(
//          task: task,
//          kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
//        )
//      }
//    }
//
//    let deletedListItemsWithRepeatButton = plannedListItems
//      .map {
//        TaskListSection(
//          header: "",
//          mode: .repeatButton,
//          items: $0
//        )
//      }

    let navigateBack = input.backButtonClickTrigger
      .map { _ in AppStep.navigateBack }
      .do { step in self.steps.accept(step) }
    
    return Output(
      // header
      navigateBack: navigateBack,
      // task list
      taskListSections: taskListSections,
      // alert
      deleteAlertText: deleteAlertText,
      deleteAlertIsHidden: deleteAlertIsHidden,
      // task
     // addTask: addTask,
      openTask: openTask,
      saveTask: saveTask
    )
  }

  func addTaskButtonIsHidden() -> Bool {
    switch self.taskListMode {
    case .main, .idea:
      return false
    default:
      return true
    }
  }

  func getTitle(with mode: TaskListMode) -> String {
    switch mode {
    case .deleted:
      return "Удаленные задачи"
    case .idea:
      return "Ящик идей"
    case .overdued:
      return "Просроченные задачи"
    default:
      return ""
    }
  }
}
