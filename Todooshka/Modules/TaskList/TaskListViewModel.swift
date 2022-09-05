//
//  TaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

enum RemoveMode: Equatable {
  case Task(task: Task)
  case Tasks(tasks: [Task])
}

class TaskListViewModel: Stepper {
  
  //MARK: - Properties
  let changeStatus = BehaviorRelay<(IndexPath, TaskStatus, Date?)?>(value: nil)
  let mode: TaskListMode
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  var editingIndexPath: IndexPath?

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
    let removeAllDeletedTasksButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let addTask: Driver<Void>
    let changeStatus: Driver<Void>
    let hideAlert: Driver<Void>
    let hideCell: Driver<IndexPath>
    let navigateBack: Driver<Void>
    let openTask: Driver<Void>
    let removeTask: Driver<Void>
    let reloadData: Driver<Void>
    let setAlertText: Driver<String>
    let setDataSource: Driver<[TaskListSectionModel]>
    let setTitle: Driver<String>
    let showAlert: Driver<Void>
    let showAddTaskButton: Driver<Void>
    let showRemovaAllButton: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices, mode: TaskListMode) {
    self.services = services
    self.mode = mode
  }
  
  func transform(input: Input) -> Output {
    
    // tasks
    let tasks = services.tasksService.tasks
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
            return task.status == .Completed && Calendar.current.isDate(date, inSameDayAs: date)
          }
        }
      }
      .asDriver(onErrorJustReturn: [])
    
    // types
    let types = services.typesService.types.asDriver()
    
    let changeStatusTrigger = changeStatus.asDriver()
    
    let removeTaskIsRequired = changeStatusTrigger
      .compactMap{ $0 }
      .filter{ $0.1 == .Deleted }
      .map{ $0.0 }

    // navigateBack
    let navigateBack = input.backButtonClickTrigger
      .map { _ in
        self.steps.accept(AppStep.TaskListIsCompleted)
      }
    
    // dataSource
    let dataSource = Driver
      .combineLatest(tasks, types) { tasks, types -> [TaskListSectionItem] in
        tasks.map { task in
          TaskListSectionItem(
            task: task,
            type: types.first(where: { $0.UID == task.typeUID }) ?? TaskType.Standart.Empty
          )
        }
      }.map {
        [
          TaskListSectionModel(header: "", mode: self.mode == .Main ? TaskCellMode.WithTimer : TaskCellMode.WithRepeatButton , items: $0)
        ]
      }
    
    let changeStatus = changeStatusTrigger
      .compactMap{ $0 }
      .filter{ $0.1 == .Idea || $0.1 == .Completed || $0.1 == .InProgress }
      .withLatestFrom(dataSource) { data, dataSource -> Void in
        let (indexPath, status, closed) = data
        var task = dataSource[indexPath.section].items[indexPath.item].task
        task.status = status
        task.closed = closed
        self.services.tasksService.saveTasksToCoreData(tasks: [task])
      }
    
    // selection
    let openTask = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> TaskListSectionItem in
        dataSource[indexPath.section].items[indexPath.item] }
      .map { item in
        self.steps.accept(AppStep.ShowTaskIsRequired(task: item.task))
      }
    
    // RemoveMode
    let setRemoveModeRemoveTask = removeTaskIsRequired
      .compactMap{ $0 }
      .withLatestFrom(dataSource) { indexPath, dataSource -> RemoveMode in
        RemoveMode.Task(task: dataSource[indexPath.section].items[indexPath.item].task )
      }.asDriver()
    
    let setRemoveModeRemoveAll = input.removeAllDeletedTasksButtonClickTrigger
      .withLatestFrom(tasks) { _, tasks -> RemoveMode in
        RemoveMode.Tasks(tasks: tasks.filter{ $0.status == .Deleted } )
      }
      .asDriver()
    
    let removeMode = Driver
      .of(setRemoveModeRemoveTask, setRemoveModeRemoveAll)
      .merge()
      .debug()
  
    // alert
    let alertText = removeMode
      .map { mode -> String in
         if case .Tasks(_) = mode { return "Удалить ВСЕ задачи?" } else { return "Удалить задачу?" }
      }
    
    let showAlert = removeMode.map{ _ -> Void in () }
    let hideAlert = Driver
      .of(input.alertCancelButtonClick, input.alertDeleteButtonClick)
      .merge()
    
    let hideCell = hideAlert
      .withLatestFrom(removeTaskIsRequired) { $1 }
      .compactMap{ $0 }
      .debug()
    
    let removeTask = input.alertDeleteButtonClick
      .withLatestFrom(removeMode) { _, mode in
        switch mode {
        case .Tasks(let tasks):
          self.services.tasksService.removeTasksFromCoreData(tasks: tasks)
        case .Task(var task):
          task.status = .Deleted
          self.services.tasksService.saveTasksToCoreData(tasks: [task])
          self.services.gameCurrencyService.removeGameCurrency(task: task)
        }
      }
    
    let addTask = input.addTaskButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.CreateTaskIsRequired(status: .Idea, createdDate: Date())) }
    
    // title
     let setTitle = Driver.just(self.getTitle(with: self.mode))
    
    let showAddTaskButton = Driver.of(self.mode)
      .filter { $0 == .Idea }
      .map{ _ in () }
    
    let showRemovaAllButton = Driver.of(self.mode)
      .filter { $0 == .Deleted }
      .map{ _ in () }
    
    let reloadData = Observable<Int>
      .timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
      .debug()
      .asDriver(onErrorJustReturn: 0)
      .filter{ _ in self.editingIndexPath == nil }
      .map{ _ in () }
 

    return Output(
      addTask: addTask,
      changeStatus: changeStatus,
      hideAlert: hideAlert,
      hideCell: hideCell,
      navigateBack: navigateBack,
      openTask: openTask,
      removeTask: removeTask,
      reloadData: reloadData,
      setAlertText: alertText,
      setDataSource: dataSource,
      setTitle: setTitle,
      showAlert: showAlert,
      showAddTaskButton: showAddTaskButton,
      showRemovaAllButton: showRemovaAllButton
    )
  }
  
  // Helpers
  func viewWillAppear() {
    services.tasksService.reloadDataSource.accept(())
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
    default:
      return ""
    }
  }

  func changeStatus(indexPath: IndexPath, status: TaskStatus, completed: Date?) {
    changeStatus.accept((indexPath, status, completed))
  }
  
}
