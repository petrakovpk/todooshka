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
  case One(task: Task)
  case All(tasks: [Task])
}

struct ChangeStatus {
  let closed: Date?
  let indexPath: IndexPath
  let status: TaskStatus
}

class TaskListViewModel: Stepper {
  
  // MARK: - Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let changeStatusTrigger = BehaviorRelay<ChangeStatus?>(value: nil)
  let mode: TaskListMode
  let reloadData = BehaviorRelay<Void>(value: ())
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  var editingIndexPath: IndexPath?
  var managedContext: NSManagedObjectContext { self.appDelegate.persistentContainer.viewContext }
  
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
    let change: Driver<Result<Void,Error>>
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
  
  //MARK: - Init
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
          case .Main:
            return task.is24hoursPassed == false && task.status == .InProgress
          case .Overdued:
            return task.is24hoursPassed && task.status == .InProgress
          case .Deleted:
            return task.status == .Deleted
          case .Idea:
            return task.status == .Idea
          case .Completed(let date):
            return task.status == .Completed && Calendar.current.isDate(date, inSameDayAs: task.closed ?? Date())
          case .Planned(let planned):
            return task.status == .Planned && Calendar.current.isDate(planned, inSameDayAs: task.planned ?? Date())
          }
        }
      }

    
    
    let taskListSectionItems = Driver
      .combineLatest(tasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
        tasks
          .sorted { (prevTask, nextTask) -> Bool in
            if self.mode == .Idea {
              let prevIndex = kindsOfTask.first{ $0.UID == prevTask.kindOfTaskUID }?.index ?? 0
              let nextIndex = kindsOfTask.first{ $0.UID == nextTask.kindOfTaskUID}?.index ?? 0
              return prevIndex == nextIndex ? prevTask.text < nextTask.text : prevIndex < nextIndex
            } else {
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
          mode: self.mode == .Main ? TaskCellMode.WithTimer : TaskCellMode.WithRepeatButton ,
          items: $0
        )
      ]}
      .asDriver()
      .do {
        print("4321 datasource", $0.first?.items.count)
      }
    
    let changeStatus = changeStatusTrigger
      .asDriver()
      .compactMap{ $0 }

    let changeToIdea = changeStatus
      .filter{ $0.status == .Idea }
      .withLatestFrom(dataSource) { changeStatus, dataSource -> Task in
        dataSource[changeStatus.indexPath.section].items[changeStatus.indexPath.item].task
      }
      .change(status: .Idea)
      .change(planned: nil)
      .asObservable()
      .flatMapLatest({ self.managedContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      
    let changeToInProgress = changeStatus
      .filter{ $0.status == .InProgress }
      .withLatestFrom(dataSource) { changeStatus, dataSource -> Task in
        dataSource[changeStatus.indexPath.section].items[changeStatus.indexPath.item].task
      }
      .change(status: .InProgress)
      .change(planned: Date())
      .change(created: Date())
      .asObservable()
      .flatMapLatest({ self.managedContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let changeToCompleted = changeStatus
      .filter{ $0.status == .Completed }
      .withLatestFrom(dataSource) { changeStatus, dataSource -> Task in
        var task = dataSource[changeStatus.indexPath.section].items[changeStatus.indexPath.item].task
        task.status = .Completed
        task.closed = changeStatus.closed
        return task
      }.asObservable()
      .flatMapLatest({ self.managedContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let changeToRemove = changeStatus
      .filter{ $0.status == .Deleted }
    
    let change = Driver
      .of(changeToIdea, changeToInProgress, changeToCompleted)
      .merge()
      .do { _ in self.reloadData.accept(()) }
 
    // selection
    let openTask = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> TaskListSectionItem in
        dataSource[indexPath.section].items[indexPath.item] }
      .map { self.steps.accept(AppStep.ShowTaskIsRequired(task: $0.task )) }
    
    let removeModeOne = changeToRemove
      .withLatestFrom(dataSource) { changeStatus, dataSource -> Task in
        dataSource[changeStatus.indexPath.section].items[changeStatus.indexPath.item].task
      }.map{ RemoveMode.One(task: $0) }
      
    let removeModeAll = input.removeAllButtonClickTrigger
      .withLatestFrom(tasks) { $1 }
      .map{ RemoveMode.All(tasks: $0) }
    
    let removeMode = Driver
      .of(removeModeOne, removeModeAll)
      .merge()
  
    // alert
    let alertText = removeMode
      .map { removeMode -> String in
        if case .All(_) = removeMode { return "Удалить ВСЕ задачи?" } else {  return "Удалить задачу?" }
      }
    
    let showAlert = removeMode
      .map { _ in () }
    
    let hideAlert = Driver
      .of(input.alertCancelButtonClick, input.alertDeleteButtonClick)
      .merge()
    
    let hideCell = hideAlert
      .withLatestFrom(changeStatus) { $1.indexPath }
      .compactMap{ $0 }
    
    let removeTask = input.alertDeleteButtonClick
      .withLatestFrom(removeMode) { $1 }
      .compactMap { removeMode -> Task? in
        guard case .One(let task) = removeMode else { return nil }
        return task
      }.change(status: .Deleted)
      .asObservable()
      .flatMapLatest({ self.managedContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let removeAll = input.alertDeleteButtonClick
      .withLatestFrom(removeMode) { $1 }
      .compactMap { removeMode -> [Task]? in
        guard case .All(let tasks) = removeMode else { return nil }
        return tasks
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .map { task -> Task in
        var task = task
        task.status = .Archive
        return task
      }
      .flatMapLatest({ self.managedContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))

    let addTask = input.addTaskButtonClickTrigger
      .compactMap { _ -> AppStep? in
        switch self.mode {
        case .Idea:
          return AppStep.CreateIdeaTaskIsRequired
        case .Planned(let date):
          return AppStep.CreatePlannedTaskIsRequired(plannedDate: date)
        default:
          return nil
        }
      }.map{ self.steps.accept($0) }
    
    // title
     let title = Driver.just(self.getTitle(with: self.mode))
    
    let addTaskButtonIsHidden = Driver<Bool>.of(self.addTaskButtonIsHidden())
    
    let showRemovaAllButton = Driver.of(self.mode)
      .filter { $0 == .Deleted }
      .map{ _ in () }
    
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
      .map { self.steps.accept(AppStep.TaskListIsCompleted) }

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
    case .Planned(_), .Idea:
      return false
    default:
      return true
    }
  }
  
  func getTitle(with mode: TaskListMode) -> String {
    switch mode {
    case .Completed(_):
      return "Выполненные задачи"
    case .Deleted:
      return "Удаленные задачи"
    case .Idea:
      return "Ящик идей"
    case .Overdued:
      return "Просроченные задачи"
    case .Planned(date: _):
      return "Запланированные задачи"
    default:
      return ""
    }
  }

  func changeStatus(indexPath: IndexPath, status: TaskStatus, completed: Date?) {
    changeStatusTrigger.accept(ChangeStatus(closed: completed, indexPath: indexPath, status: status))
  }
}
