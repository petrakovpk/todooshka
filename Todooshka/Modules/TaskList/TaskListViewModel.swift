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

struct ChangeStatus {
  let completed: Date?
  let indexPath: IndexPath
  let status: TaskStatus
}

class TaskListViewModel: Stepper {
  // MARK: - Properties
  public let steps = PublishRelay<Step>()
  public var editingIndexPath: IndexPath?
  
 
  private let services: AppServices
  private let changeStatusTrigger = BehaviorRelay<ChangeStatus?>(value: nil)
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
    // HEADER
    let title: Driver<String>
    // NAVIGATE BACK
    let navigateBack: Driver<Void>
    // MODE
    let mode: Driver<TaskListMode>
    // ADD TASK
    let addTask: Driver<Void>
   // let addTaskButtonIsHidden: Driver<Bool>
    // REMOVE ALL TASKS
    let removeAllTasks: Driver<Result<Void, Error>>
  //  let removeAllTasksButtonIsHidden: Driver<Bool>
    // DATASOURCE
    let dataSource: Driver<[TaskListSection]>
    let reloadItems: Driver<[IndexPath]>
    let hideCellWhenAlertClosed: Driver<IndexPath>
    // TASK
    let openTask: Driver<Void>
    let changeTaskStatus: Driver<Result<Void, Error>>
    let removeTask: Driver<Result<Void, Error>>
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
    let tasks = services.dataService.tasks.asDriver()
    let kindsOfTask = services.dataService.kindsOfTask.asDriver()
    
    let mode = Driver<TaskListMode>.of(self.mode)
    
    // MARK: - BACK
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.taskListIsCompleted) }
    
    // MARK: - DATASOURCE MAIN
    let mainListTasks = tasks
      .map { tasks -> [Task] in
        tasks.filter { task -> Bool in
          guard
            case .main = self.mode
          else { return false }
          
          return task.status == .inProgress &&
          task.planned.startOfDay >= Date().startOfDay &&
          task.planned.endOfDay <= Date().endOfDay
        }
        .sorted { prevTask, nextTask -> Bool in
          (prevTask.planned == nextTask.planned) ? (prevTask.created < nextTask.created) : (prevTask.planned < nextTask.planned)
        }
      }
      
    let mainListItems = Driver
      .combineLatest(mainListTasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
        tasks.map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
          )
        }
      }

    let mainListSectionWithTime = mainListItems
      .compactMap { $0.filter { $0.task.planned != Date().endOfDay } }
      .map {
        TaskListSection(
          header: "Внимание, время:",
          mode: .redLineAndTime,
          items: $0
        )
      }
    
    let mainListSectionWithoutTime = mainListItems
      .compactMap { $0.filter { $0.task.planned == Date().endOfDay } }
      .map {
        TaskListSection(
          header: "В течении дня:",
          mode: .blueLine,
          items: $0
        )
      }

    // MARK: - DATASOURCE OVERDUED
    let overduedListTasks = tasks
      .map { tasks -> [Task] in
        tasks.filter { task -> Bool in
          guard
            case .overdued = self.mode
          else { return false }
          
          return task.status == .inProgress &&
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
          guard
            case .idea = self.mode
          else { return false }
          
          return task.status == .idea
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
            
            return task.status == .completed &&
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
        mainListSectionWithTime,
        mainListSectionWithoutTime,
        overduedListSectionWithRepeatButton,
        ideaListSectionWithRepeatButton,
        completedListSectionWithRepeatButton,
        plannedListSectionWithRepeatButton,
        deletedListItemsWithRepeatButton )
    {
      mainListItemsWithTime,
      mainListItemsWithoutTime,
      overduedListTasksWithRepeatButton,
      ideaListTasksWithRepeatButton,
      completedListItemsWithRepeatButton,
      plannedListItemsWithRepeatButton,
      deletedListItemsWithRepeatButton -> [TaskListSection] in
      [
        mainListItemsWithTime,
        mainListItemsWithoutTime,
        overduedListTasksWithRepeatButton,
        ideaListTasksWithRepeatButton,
        completedListItemsWithRepeatButton,
        plannedListItemsWithRepeatButton,
        deletedListItemsWithRepeatButton
      ]
        .filter { !$0.items.isEmpty }
    }

    // MARK: - Swipe
    let changeStatus = changeStatusTrigger
      .asDriver()
      .compactMap { $0 }

    let changeToIdea = changeStatus
      .filter { $0.status == .idea }
      .withLatestFrom(dataSource) { changeStatus, dataSource -> Task in
        dataSource[changeStatus.indexPath.section].items[changeStatus.indexPath.item].task
      }
      .change(status: .idea)
      .change(planned: Date().adding(.year, value: 1))
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let changeToInProgress = changeStatus
      .filter { $0.status == .inProgress }
      .withLatestFrom(dataSource) { changeStatus, dataSource -> Task in
        dataSource[changeStatus.indexPath.section].items[changeStatus.indexPath.item].task
      }
      .change(status: .inProgress)
      .change(planned: Date())
      .change(created: Date())
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let changeToCompleted = changeStatus
      .filter { $0.status == .completed }
      .withLatestFrom(dataSource) { changeStatus, dataSource -> Task in
        var task = dataSource[changeStatus.indexPath.section].items[changeStatus.indexPath.item].task
        task.status = .completed
        task.completed = changeStatus.completed
        return task
      }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let changeToRemove = changeStatus
      .filter { $0.status == .deleted }

    let changeTaskStatus = Driver
      .of(changeToIdea, changeToInProgress, changeToCompleted)
      .merge()
      .do { _ in self.reloadData.accept(()) }

    // selection
    let openTask = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> TaskListSectionItem in
        dataSource[indexPath.section].items[indexPath.item]
      }
      .map { self.steps.accept(AppStep.showTaskIsRequired(task: $0.task )) }

    let removeModeOne = changeToRemove
      .withLatestFrom(dataSource) { changeStatus, dataSource -> Task in
        dataSource[changeStatus.indexPath.section].items[changeStatus.indexPath.item].task
      }.map { RemoveMode.one(task: $0) }

    let removeModeAll = input.removeAllButtonClickTrigger
      .withLatestFrom(tasks) { $1 }
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

    let hideCellWhenAlertClosed = hideAlert
      .withLatestFrom(changeStatus) { $1.indexPath }
      .compactMap { $0 }

    let removeTask = input.alertDeleteButtonClick
      .withLatestFrom(removeMode) { $1 }
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

    let timer = Observable<Int>
      .timer(.seconds(0), period: .seconds(60), scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: 0)

    let reloadItems = timer
      .withLatestFrom(dataSource) { _, dataSource -> [IndexPath] in
        dataSource.enumerated().flatMap { sectionIndex, section -> [IndexPath] in
          section.items.enumerated().compactMap { itemIndex, item -> IndexPath? in
            (IndexPath(item: itemIndex, section: sectionIndex) == self.editingIndexPath) ? nil : IndexPath(item: itemIndex, section: sectionIndex)
          }
        }
      }

    return Output(
      // HEADER
      title: title,
      // NAVIGATE BACK
      navigateBack: navigateBack,
      // MODE
      mode: mode,
      // ADD TASK
      addTask: addTask,
  //   addTaskButtonIsHidden: addTaskButtonIsHidden,
      // REMOVE ALL TASKS
      removeAllTasks: removeAllTasks,
   //   removeAllTasksButtonIsHidden: removeAllTasksButtonIsHidden,
      // DATASOURCE
      dataSource: dataSource,
      reloadItems: reloadItems,
      hideCellWhenAlertClosed: hideCellWhenAlertClosed,
      // TASK
      openTask: openTask,
      changeTaskStatus: changeTaskStatus,
      removeTask: removeTask,
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

  func changeStatus(indexPath: IndexPath, status: TaskStatus, completed: Date?) {
    changeStatusTrigger.accept(ChangeStatus(completed: completed, indexPath: indexPath, status: status))
  }
}
