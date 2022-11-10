//
//  TaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import CoreData
import Firebase
import RxFlow
import RxSwift
import RxCocoa
import UIKit

enum RemoveMode: Equatable {
  case one(task: Task)
  case all(tasks: [Task])
}

struct ChangeStatus {
  let closed: Date?
  let indexPath: IndexPath
  let status: TaskStatus
}

class TaskListViewModel: Stepper {
  // MARK: - Properties
  // context
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  var managedContext: NSManagedObjectContext? { appDelegate?.persistentContainer.viewContext }

  // rx
  let services: AppServices
  let steps = PublishRelay<Step>()

  let changeStatusTrigger = BehaviorRelay<ChangeStatus?>(value: nil)
  var editingIndexPath: IndexPath?
  let mode: TaskListMode
  let reloadData = BehaviorRelay<Void>(value: ())

  struct Input {
    // selection
    let selection: Driver<IndexPath>
    // alert
    let alertDeleteButtonClick: Driver<Void>
    let alertCancelButtonClick: Driver<Void>
    // back
    let backButtonClickTrigger: Driver<Void>
    // add
    let addTaskButtonClickTrigger: Driver<Void>
    // remove all
    let removeAllButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let addTask: Driver<Void>
    let addTaskButtonIsHidden: Driver<Bool>
    let change: Driver<Result<Void, Error>>
    let dataSource: Driver<[TaskListSection]>
    let hideAlert: Driver<Void>
    let hideCell: Driver<IndexPath>
    let navigateBack: Driver<Void>
    let openTask: Driver<Void>
    let removeAll: Driver<Result<Void, Error>>
    let removeTask: Driver<Result<Void, Error>>
    let reloadItems: Driver<[IndexPath]>
    let setAlertText: Driver<String>
    let title: Driver<String>
    let showAlert: Driver<Void>
    let showRemovaAllButton: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, mode: TaskListMode) {
    self.services = services
    self.mode = mode
  }

  func transform(input: Input) -> Output {
    let kindsOfTask = services.dataService
      .kindsOfTask

    let tasks = services.dataService.tasks
      .map {
        $0.filter { task in
          switch self.mode {
          case .main:
            return task.is24hoursPassed == false && task.status == .inProgress
          case .overdued:
            return task.is24hoursPassed && task.status == .inProgress
          case .deleted:
            return task.status == .deleted
          case .idea:
            return task.status == .idea
          case .completed(let date):
            return task.status == .completed && Calendar.current.isDate(date, inSameDayAs: task.closed ?? Date())
          case .planned(let planned):
            return task.status == .planned && Calendar.current.isDate(planned, inSameDayAs: task.planned ?? Date())
          }
        }
      }

    let taskListSectionItems = Driver
      .combineLatest(tasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
        tasks
          .sorted { prevTask, nextTask -> Bool in
            switch self.mode {
            case .idea:
              let prevIndex = kindsOfTask.first { $0.UID == prevTask.kindOfTaskUID }?.index ?? 0
              let nextIndex = kindsOfTask.first { $0.UID == nextTask.kindOfTaskUID }?.index ?? 0
              return prevIndex == nextIndex ? prevTask.text < nextTask.text : prevIndex < nextIndex
            case .completed:
              return prevTask.closed ?? Date() < nextTask.closed ?? Date()
            default:
              return prevTask.created < nextTask.created
            }
          }
          .map { task in
            TaskListSectionItem(
              task: task,
              kindOfTask: kindsOfTask.first(where: { $0.UID == task.kindOfTaskUID }) ?? KindOfTask.Standart.Simple
            )
          }
      }

    // dataSource
    let dataSource = taskListSectionItems
      .map {[
        TaskListSection(
          header: "",
          mode: self.mode == .main ? .withTimer : .withRepeatButton,
          items: $0
        )
      ]
      }
      .asDriver()

    let changeStatus = changeStatusTrigger
      .asDriver()
      .compactMap { $0 }

    let changeToIdea = changeStatus
      .filter { $0.status == .idea }
      .withLatestFrom(dataSource) { changeStatus, dataSource -> Task in
        dataSource[changeStatus.indexPath.section].items[changeStatus.indexPath.item].task
      }
      .change(status: .idea)
      .change(planned: nil)
      .asObservable()
      .flatMapLatest({ self.managedContext?.rx.update($0) ?? Observable.of(.failure(ErrorType.driverError)) })
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
      .flatMapLatest({ self.managedContext?.rx.update($0) ?? Observable.of(.failure(ErrorType.driverError)) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let changeToCompleted = changeStatus
      .filter { $0.status == .completed }
      .withLatestFrom(dataSource) { changeStatus, dataSource -> Task in
        var task = dataSource[changeStatus.indexPath.section].items[changeStatus.indexPath.item].task
        task.status = .completed
        task.closed = changeStatus.closed
        return task
      }.asObservable()
      .flatMapLatest({ self.managedContext?.rx.update($0) ?? Observable.of(.failure(ErrorType.driverError)) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let changeToRemove = changeStatus
      .filter { $0.status == .deleted }

    let change = Driver
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

    let hideCell = hideAlert
      .withLatestFrom(changeStatus) { $1.indexPath }
      .compactMap { $0 }

    let removeTask = input.alertDeleteButtonClick
      .withLatestFrom(removeMode) { $1 }
      .compactMap { removeMode -> Task? in
        guard case .one(let task) = removeMode else { return nil }
        return task
      }.change(status: .deleted)
      .asObservable()
      .flatMapLatest({ self.managedContext?.rx.update($0) ?? Observable.of(.failure(ErrorType.driverError)) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let removeAll = input.alertDeleteButtonClick
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
      .flatMapLatest({ self.managedContext?.rx.update($0) ?? Observable.of(.failure(ErrorType.driverError)) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let addTask = input.addTaskButtonClickTrigger
      .compactMap { _ -> AppStep? in
        switch self.mode {
        case .idea:
          return AppStep.createIdeaTaskIsRequired
        case .planned(let date):
          return AppStep.createPlannedTaskIsRequired(plannedDate: date)
        default:
          return nil
        }
      }.map { self.steps.accept($0) }

    // title
     let title = Driver.just(self.getTitle(with: self.mode))

    let addTaskButtonIsHidden = Driver<Bool>.of(self.addTaskButtonIsHidden())

    let showRemovaAllButton = Driver.of(self.mode)
      .filter { $0 == .deleted }
      .map { _ in () }

    let timer = Observable<Int>
      .timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: 0)

    let reloadItems = timer
      .withLatestFrom(dataSource) { _, dataSource -> [IndexPath] in
        dataSource.enumerated().flatMap { sectionIndex, section -> [IndexPath] in
          section.items.enumerated().compactMap { itemIndex, item -> IndexPath? in
            (IndexPath(item: itemIndex, section: sectionIndex) == self.editingIndexPath) ? nil : IndexPath(item: itemIndex, section: sectionIndex)
          }
        }
      }

    // navigateBack
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.taskListIsCompleted) }

    return Output(
      addTask: addTask,
      addTaskButtonIsHidden: addTaskButtonIsHidden,
      change: change,
      dataSource: dataSource,
      hideAlert: hideAlert,
      hideCell: hideCell,
      navigateBack: navigateBack,
      openTask: openTask,
      removeAll: removeAll,
      removeTask: removeTask,
      reloadItems: reloadItems,
      setAlertText: alertText,
      title: title,
      showAlert: showAlert,
      showRemovaAllButton: showRemovaAllButton
    )
  }

  func addTaskButtonIsHidden() -> Bool {
    switch self.mode {
    case .planned, .idea:
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
    case .planned(date: _):
      return "Запланированные задачи"
    default:
      return ""
    }
  }

  func changeStatus(indexPath: IndexPath, status: TaskStatus, completed: Date?) {
    changeStatusTrigger.accept(ChangeStatus(closed: completed, indexPath: indexPath, status: status))
  }
}
