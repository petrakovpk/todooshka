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
    let removeAllButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let addTask: Driver<Void>
    let changeToCompleted: Driver<Void>
    let changeToIdea: Driver<Void>
    let changeToInProgress: Driver<Void>
    let hideAlert: Driver<Void>
    let hideCell: Driver<IndexPath>
    let navigateBack: Driver<Void>
    let openTask: Driver<Void>
    let removeTask: Driver<Void>
    let reloadData: Driver<[IndexPath]>
    let setAlertText: Driver<String>
    let setDataSource: Driver<[TaskListSectionModel]>
    let title: Driver<String>
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
          }
        }
      }
      .asDriver(onErrorJustReturn: [])
    
    // kindsOfTask
    let kindsOfTask = services.dataService.kindsOfTask.asDriver()
    
    // dataSource
    let dataSource = Driver
      .combineLatest(tasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
        tasks.map { task in
          TaskListSectionItem(
            task: task,
            kindOfTask: kindsOfTask.first(where: { $0.UID == task.kindOfTaskUID }) ?? KindOfTask.Standart.Empty
          )
        }
      }.map {[ TaskListSectionModel(header: "", mode: self.mode == .Main ? TaskCellMode.WithTimer : TaskCellMode.WithRepeatButton , items: $0) ]}
    
    let changeStatus = changeStatus
      .asDriver()
      .compactMap{ $0 }

    let changeToIdea = changeStatus
      .filter{ $0.1 == .Idea }
      .compactMap{ $0.0 }
      .withLatestFrom(dataSource) { indexPath, dataSource -> Task in
        dataSource[indexPath.section].items[indexPath.item].task
      }
//        self.services.tasksService.saveTasksToCoreData(tasks: [task])
      
    
    let changeToInProgress = changeStatus
      .filter{ $0.1 == .InProgress }
      .compactMap{ $0.0 }
      .withLatestFrom(dataSource) { indexPath, dataSource -> Void in
        var task = dataSource[indexPath.section].items[indexPath.item].task
        task.status = .InProgress
        task.created = Date()
   //     self.services.tasksService.saveTasksToCoreData(tasks: [task])
      }
    
    let changeToCompleted = changeStatus
      .filter{ $0.1 == .Completed }
      .withLatestFrom(dataSource) { data, dataSource -> Void in
        var task = dataSource[data.0.section].items[data.0.item].task
        task.status = .Completed
        task.closed = data.2
     //   self.services.tasksService.saveTasksToCoreData(tasks: [task])
      }
    
    let changeToRemoved = changeStatus
      .filter{ $0.1 == .Deleted }

    // navigateBack
    let navigateBack = input.backButtonClickTrigger
      .map { _ in
        self.steps.accept(AppStep.TaskListIsCompleted)
      }
    
    // selection
    let openTask = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> TaskListSectionItem in
        dataSource[indexPath.section].items[indexPath.item] }
      .map { item in
        self.steps.accept(AppStep.ShowTaskIsRequired(task: item.task))
      }
    
    // RemoveMode
    let setRemoveModeRemoveTask = changeToRemoved
      .compactMap{ $0.0 }
      .withLatestFrom(dataSource) { indexPath, dataSource -> RemoveMode in
        RemoveMode.Task(task: dataSource[indexPath.section].items[indexPath.item].task )
      }.asDriver()
    
    let setRemoveModeRemoveAll = input.removeAllButtonClickTrigger
      .withLatestFrom(tasks) { _, tasks -> RemoveMode in
        RemoveMode.Tasks(tasks: tasks.filter{ $0.status == .Deleted } )
      }
      .asDriver()
    
    let removeMode = Driver
      .of(setRemoveModeRemoveTask, setRemoveModeRemoveAll)
      .merge()
  
    // alert
    let alertText = removeMode
      .map { mode -> String in
         if case .Tasks(_) = mode {
           return "Удалить ВСЕ задачи?" }
        else {
          return "Удалить задачу?" }
      }
    
    let showAlert = removeMode
      .map { _ -> Void in () }
    
    let hideAlert = Driver
      .of(input.alertCancelButtonClick, input.alertDeleteButtonClick)
      .merge()
    
    let hideCell = hideAlert
      .withLatestFrom(changeToRemoved) { $1.0 }
      .compactMap{ $0 }
    
    let removeTask = input.alertDeleteButtonClick
      .withLatestFrom(removeMode) { _, mode in
        switch mode {
        case .Tasks(let tasks):
          self.editingIndexPath = nil
        //  self.services.tasksService.removeTasksFromCoreData(tasks: tasks)
        case .Task(var task):
          task.status = .Deleted
          self.editingIndexPath = nil
      //    self.services.tasksService.saveTasksToCoreData(tasks: [task])
          self.services.gameCurrencyService.removeGameCurrency(task: task)
        }
      }
    
    let addTask = input.addTaskButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.CreateTaskIsRequired(status: .Idea, createdDate: Date())) }
    
    // title
     let title = Driver.just(self.getTitle(with: self.mode))
    
    let showAddTaskButton = Driver.of(self.mode)
      .filter { $0 == .Idea }
      .map{ _ in () }
    
    let showRemovaAllButton = Driver.of(self.mode)
      .filter { $0 == .Deleted }
      .map{ _ in () }
    
    let timer = Observable<Int>
      .timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: 0)
    
    let reloadData = timer
      .withLatestFrom(dataSource) { _, dataSource -> [IndexPath] in
        dataSource.enumerated().flatMap { sectionIndex, section -> [IndexPath] in
          section.items.enumerated().compactMap { itemIndex, item -> IndexPath? in
            (IndexPath(item: itemIndex, section: sectionIndex) == self.editingIndexPath) ? nil : IndexPath(item: itemIndex, section: sectionIndex)
          }
        }
    }

    return Output(
      addTask: addTask,
      changeToCompleted: changeToCompleted,
      changeToIdea: changeToIdea,
      changeToInProgress: changeToInProgress,
      hideAlert: hideAlert,
      hideCell: hideCell,
      navigateBack: navigateBack,
      openTask: openTask,
      removeTask: removeTask,
      reloadData: reloadData,
      setAlertText: alertText,
      setDataSource: dataSource,
      title: title,
      showAlert: showAlert,
      showAddTaskButton: showAddTaskButton,
      showRemovaAllButton: showRemovaAllButton
    )
  }
  
  // Helpers
  func viewWillAppear() {
  //  services.tasksService.reloadDataSource.accept(())
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
