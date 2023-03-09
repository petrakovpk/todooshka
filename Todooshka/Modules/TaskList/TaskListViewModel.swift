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

enum RemoveMode: Equatable {
  case one(task: Task)
  case all(tasks: [Task])
}

class TaskListViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let inProgressButtonClickTrigger = PublishRelay<IndexPath>()
  public let swipeDeleteButtonClickTrigger = PublishRelay<IndexPath>()
  public let swipeIdeaButtonClickTrigger = PublishRelay<IndexPath>()
  
  private let services: AppServices
  private let mode: TaskListMode
  private let reloadData = BehaviorRelay<Void>(value: ())
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  private var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }
  
  struct Input {
    // BACK
    let backButtonClickTrigger: Driver<Void>
    // ADD
    let addTaskButtonClickTrigger: Driver<Void>
    // REMOVE ALL
    let removeAllButtonClickTrigger: Driver<Void>
    // SELECT TASK
    let selection: Driver<IndexPath>
    // ALERT
    let alertDeleteButtonClick: Driver<Void>
    let alertCancelButtonClick: Driver<Void>
  }

  struct Output {
    // INIT
    let mode: Driver<TaskListMode>
    // NAVIGATE BACK
    let navigateBack: Driver<Void>
    // TITLE
    let title: Driver<String>
    // ADD TASK
    let addTask: Driver<Void>
    // REMOVE ALL TASKS
    let removeAllTasks: Driver<Result<Void, Error>>
    // DATASOURCE
    let dataSource: Driver<[TaskListSection]>
    let hideCellWhenAlertClosed: Driver<IndexPath>
    // TASK
    let openTask: Driver<Void>
    let changeTaskStatusToIdea: Driver<Result<Void, Error>>
    let changeTaskStatusToDeleted: Driver<Result<Void, Error>>
    let changeTaskStatusToInProgress: Driver<Result<Void, Error>>
    // ALERT
    let alertText: Driver<String>
    let showAlert: Driver<Void>
    let hideAlert: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, mode: TaskListMode) {
    self.services = services
    self.mode = mode
  }

  func transform(input: Input) -> Output {
    // MARK: - INIT
    let tasks = managedContext
      .rx
      .entities(Task.self)
      .asDriverOnErrorJustComplete()
    
    let kindsOfTask = managedContext
      .rx
      .entities(KindOfTask.self)
      .asDriverOnErrorJustComplete()
    
    let mode = Driver<TaskListMode>.of(self.mode)
    
    let swipeIdeaButtonClickTrigger = swipeIdeaButtonClickTrigger
      .asDriverOnErrorJustComplete()
    
    let swipeDeleteButtonClickTrigger = swipeDeleteButtonClickTrigger
      .asDriverOnErrorJustComplete()
    
    let inProgressButtonClickTrigger = inProgressButtonClickTrigger
      .asDriverOnErrorJustComplete()
    
    // MARK: - BACK
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.taskListIsCompleted) }
    
    // MARK: - DATASOURCE OVERDUED
    let overduedListTasks = tasks
      .map { tasks -> [Task] in
        tasks.filter { task -> Bool in
          self.mode == .overdued &&
          task.status == .inProgress &&
          task.planned.startOfDay < Date().startOfDay
        }
        .sorted { prevTask, nextTask -> Bool in
          prevTask.created < nextTask.created
        }
      }
    
    let overduedListItems = Driver.combineLatest(overduedListTasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
      tasks.map { task -> TaskListSectionItem in
        TaskListSectionItem(
          task: task,
          kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
        )
      }
    }
    
    let overduedListSectionWithRepeatButton = overduedListItems
      .map {
        TaskListSection(
          header: "",
          mode: .repeatButton,
          items: $0
        )
      }
    
    // MARK: - DATASOURCE IDEA
    let ideaListTasks = tasks
      .map { tasks -> [Task] in
        tasks.filter { task -> Bool in
          self.mode == .idea &&
          task.status == .idea
        }
      }
    
    let ideaListItems = Driver
      .combineLatest(ideaListTasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
        tasks
          .sorted { prevTask, nextTask -> Bool in
            guard
              let prevIndex = kindsOfTask.first { $0.UID == prevTask.kindOfTaskUID }?.index,
              let nextIndex = kindsOfTask.first { $0.UID == nextTask.kindOfTaskUID }?.index
            else { return false }
            
            return (prevIndex == nextIndex) ? (prevTask.text < nextTask.text) : (prevIndex < nextIndex)
          }
          .map { task -> TaskListSectionItem in
            TaskListSectionItem(
              task: task,
              kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
            )
          }
      }
    
    let ideaListSectionWithRepeatButton = ideaListItems
      .map {
        TaskListSection(
          header: "",
          mode: .repeatButton,
          items: $0
        )
      }
    
    // MARK: - DATASOURCE COMPLETED
    let completedListTasks = tasks
      .map { tasks -> [Task] in
        tasks
          .filter { task -> Bool in
            guard
              case .completed(let completedDate) = self.mode,
              let completed = task.completed
            else { return false }
            
            return (task.status == .completed || task.status == .published) &&
            completed.startOfDay >= completedDate.startOfDay &&
            completed.endOfDay <= completedDate.endOfDay
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
    
    let completedListSectionWithRepeatButton = completedListItems
      .map {
        TaskListSection(
          header: "",
          mode: .repeatButton,
          items: $0
        )
      }
    
    // MARK: - PLANNED COMPLETED
    let plannedListTasks = tasks
      .map { tasks -> [Task] in
        tasks.filter { task -> Bool in
          guard
            case .planned(let planned) = self.mode
          else { return false }
          
          return task.status == .inProgress &&
          task.planned.startOfDay >= planned.startOfDay &&
          task.planned.endOfDay <= planned.endOfDay
        }
        .sorted { prevTask, nextTask -> Bool in
          prevTask.created < nextTask.created
        }
      }
    
    let plannedListItems = Driver.combineLatest(plannedListTasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
      tasks.map { task -> TaskListSectionItem in
        TaskListSectionItem(
          task: task,
          kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
        )
      }
    }
    
    let plannedListSectionWithRepeatButton = plannedListItems
      .map {
        TaskListSection(
          header: "PLANNED",
          mode: .repeatButton,
          items: $0
        )
      }
    
    // MARK: - DELETED COMPLETED
    let deletedListTasks = tasks
      .map { tasks -> [Task] in
        tasks.filter { task -> Bool in
          guard
            case .deleted = self.mode
          else { return false }
          
          return task.status == .deleted
        }
        .sorted { prevTask, nextTask -> Bool in
          prevTask.created < nextTask.created
        }
      }
    
    let deletedListItems = Driver.combineLatest(deletedListTasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
      tasks.map { task -> TaskListSectionItem in
        TaskListSectionItem(
          task: task,
          kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
        )
      }
    }
    
    let deletedListItemsWithRepeatButton = plannedListItems
      .map {
        TaskListSection(
          header: "",
          mode: .repeatButton,
          items: $0
        )
      }
    
    // MARK: - DATASOURCE
    let dataSource = Driver
      .combineLatest(
        overduedListSectionWithRepeatButton,
        ideaListSectionWithRepeatButton,
        completedListSectionWithRepeatButton,
        plannedListSectionWithRepeatButton,
        deletedListItemsWithRepeatButton )
    {
      overduedListTasksWithRepeatButton,
      ideaListTasksWithRepeatButton,
      completedListItemsWithRepeatButton,
      plannedListItemsWithRepeatButton,
      deletedListItemsWithRepeatButton -> [TaskListSection] in
      [
        overduedListTasksWithRepeatButton,
        ideaListTasksWithRepeatButton,
        completedListItemsWithRepeatButton,
        plannedListItemsWithRepeatButton,
        deletedListItemsWithRepeatButton
      ]
    }.map {
      $0.filter { !$0.items.isEmpty }
    }

    // MARK: - Change STATUS
    let changeTaskStatusToInProgress = inProgressButtonClickTrigger
      .withLatestFrom(dataSource) { indexPath, dataSource -> Task in
        dataSource[indexPath.section].items[indexPath.item].task
      }
      .change(status: .inProgress)
      .change(created: Date())
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
    
    let changeTaskStatusToIdea = swipeIdeaButtonClickTrigger
      .withLatestFrom(dataSource) { indexPath, dataSource -> Task in
        dataSource[indexPath.section].items[indexPath.item].task
      }
      .change(status: .idea)
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let removeModeOne = swipeDeleteButtonClickTrigger
      .withLatestFrom(dataSource) { indexPath, dataSource -> Task in
        dataSource[indexPath.section].items[indexPath.item].task
      }
      .map { RemoveMode.one(task: $0) }
    
    // selection
    let openTask = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> TaskListSectionItem in
        dataSource[indexPath.section].items[indexPath.item]
      }
      .map { self.steps.accept(AppStep.showTaskIsRequired(task: $0.task )) }

    let removeModeAll = input.removeAllButtonClickTrigger
      .withLatestFrom(tasks)
      .map { RemoveMode.all(tasks: $0) }

    let removeMode = Driver
      .of(removeModeOne, removeModeAll)
      .merge()

    // alert
    let alertText = removeMode
      .map { removeMode -> String in
        if case .all = removeMode { return "Удалить ВСЕ задачи?" } else {  return "Удалить задачу?" }
      }

    let showAlert = removeMode
      .map { _ in () }

    let hideAlert = Driver
      .of(input.alertCancelButtonClick, input.alertDeleteButtonClick)
      .merge()
    
    let changingIndexPath = Driver.of(
      swipeIdeaButtonClickTrigger,
      swipeDeleteButtonClickTrigger,
      inProgressButtonClickTrigger
    )
      .merge()

    let hideCellWhenAlertClosed = hideAlert
      .withLatestFrom(changingIndexPath)
      .compactMap { $0 }

    let changeTaskStatusToDeleted = input.alertDeleteButtonClick
      .withLatestFrom(removeMode)
      .compactMap { removeMode -> Task? in
        guard case .one(let task) = removeMode else { return nil }
        return task
      }
      .change(status: .deleted)
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let removeAllTasks = input.alertDeleteButtonClick
      .withLatestFrom(removeMode) { $1 }
      .compactMap { removeMode -> [Task]? in
        guard case .all(let tasks) = removeMode else { return nil }
        return tasks
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .map { task -> Task in
        var task = task
        task.status = .archive
        return task
      }
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let addTask = input.addTaskButtonClickTrigger
      .compactMap { _ -> AppStep? in
        switch self.mode {
        case .idea:
          return AppStep.createTaskIsRequired(task: Task(UID: UUID().uuidString, status: .idea), isModal: false)
        case .planned(let date):
          return AppStep.createTaskIsRequired(task: Task(UID: UUID().uuidString, status: .inProgress, planned: date, completed: nil), isModal: false)
        default:
          return nil
        }
      }
      .map { self.steps.accept($0) }

    // title
    let title = Driver.just(self.getTitle(with: self.mode))

    let addTaskButtonIsHidden = Driver<Bool>.of(self.addTaskButtonIsHidden())

    let removeAllTasksButtonIsHidden = Driver.of(self.mode)
      .map { $0 == .deleted }

    

    return Output(
      // MODE
      mode: mode,
      // NAVIGATE BACK
      navigateBack: navigateBack,
      // HEADER
      title: title,
      // ADD TASK
      addTask: addTask,
      // REMOVE ALL TASKS
      removeAllTasks: removeAllTasks,
      // DATASOURCE
      dataSource: dataSource,
     // reloadItems: reloadItems,
      hideCellWhenAlertClosed: hideCellWhenAlertClosed,
      // TASK
      openTask: openTask,
      changeTaskStatusToIdea: changeTaskStatusToIdea,
      changeTaskStatusToDeleted: changeTaskStatusToDeleted,
      changeTaskStatusToInProgress: changeTaskStatusToInProgress,
      // ALERT
      alertText: alertText,
      showAlert: showAlert,
      hideAlert: hideAlert
    )
  }

  func addTaskButtonIsHidden() -> Bool {
    switch self.mode {
    case .main, .idea:
      return false
    default:
      return true
    }
  }

  func getTitle(with mode: TaskListMode) -> String {
    switch mode {
    case .completed:
      return "Выполненные задачи"
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

//  func changeStatus(indexPath: IndexPath, status: TaskStatus, completed: Date?) {
//    changeStatusTrigger.accept(ChangeStatus(completed: completed, indexPath: indexPath, status: status))
//  }
}
