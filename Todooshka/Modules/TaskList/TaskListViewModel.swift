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

enum RemoveMode {
  case DeletedTasks
  case Task(task: Task)
}

class TaskListViewModel: Stepper {
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  let listType: ListType
  var removeMode: RemoveMode?
  
  struct Input {
    // selection
    let selection: Driver<IndexPath>
    // alert
    let alertDeleteButtonClick: Driver<Void>
    let alertCancelButtonClick: Driver<Void>
    // back
    let backButtonClickTrigger: Driver<Void>?
    // add
    let addTaskButtonClickTrigger: Driver<Void>?
    // remove all
    let removeAllDeletedTasksButtonClickTrigger: Driver<Void>?
  }
  
  struct Output {
    // dataSource
    let dataSource: Driver<[TaskListSectionModel]>
    // selection
    let selection: Driver<Task>
    // alert
    let alertText: Driver<String>
    let alertDeleteButtonClick: Driver<Void>
    let alertCancelButtonClick: Driver<Void>
    let alertIsHidden: Driver<Bool>
    // back
    let backButtonClick: Driver<Void>?
    // addTask
    let addTaskButtonClick: Driver<Void>?
    let addTaskButtonIsHidden: Driver<Bool>
    // title
    let title: Driver<String>
    // remove all
    let removeAllDeletedTasksButtonClick: Driver<Void>?
    let removeAllDeletedTasksButtonIsHidden: Driver<Bool>
  }
  
  //MARK: - Init
  init(services: AppServices, type: ListType) {
    self.services = services
    self.listType = type
  }
  
  func transform(input: Input) -> Output {
    
    // tasks
    let tasks = services.tasksService.tasks
      .map {
        $0.filter { task in
          switch self.listType {
          case .Main:
            return task.is24hoursPassed == false && task.status == .Created
          case .Overdued:
            return task.is24hoursPassed && task.status == .Created
          case .Deleted:
            return task.status == .Deleted
          case .Idea:
            return task.status == .Idea
          case .Completed(let date):
            guard let closed = task.closed else { return false }
            return task.status == .Completed && Calendar.current.isDate(closed, inSameDayAs: date)
          }
        }
      }
      .asDriver(onErrorJustReturn: [])
    
    // dataSource
    let dataSource = tasks
      .map { [TaskListSectionModel(header: "", items: $0)] }
    
    // selection
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource in
        return dataSource[indexPath.section].items[indexPath.item]
      }
      .do { task in
        self.steps.accept(AppStep.ShowTaskIsRequired(task: task))
      }
    
    // title
    let title = Driver.just(self.getTitle(with: self.listType))
    
    // backButtonClick
    let backButtonClick = input.backButtonClickTrigger?
      .do { _ in
        self.steps.accept(AppStep.TaskListIsCompleted)
      }
    
    // addTaskButton
    let addTaskButtonIsHidden = Driver.just(self.addTaskButtonIsHidden(with: self.listType))
    let addTaskButtonClick = input.addTaskButtonClickTrigger?
      .do{ _ in
        self.steps.accept(AppStep.CreateTaskIsRequired(status: .Idea, createdDate: Date()))
      }
    
    // remove all
    let removeAllTasksButtonIsHidden = Driver.just(self.removeAllTasksButtonIsHIdden(with: self.listType))
    let removeAllTasksButtonClick = input.removeAllDeletedTasksButtonClickTrigger?
      .do { _ in
        self.services.tasksService.removeTrigger.accept(.DeletedTasks)
      }
    
    // removeMode
    let removeMode = services.tasksService.removeTrigger
      .asDriver()
    
    // alert
    let alertText = removeMode
      .map { mode -> String in
        switch mode {
        case .DeletedTasks:
          return "Удалить ВСЕ задачи?"
        case .Task(_):
          return "Удалить задачу?"
        default:
          return ""
        }
      }
    
    // alertIsHidden
    let alertIsHidden = removeMode
      .map { $0 == nil }
      .asDriver(onErrorJustReturn: false)
    
    // alert delete button click
    let alertDeleteButtonClick = input.alertDeleteButtonClick
      .withLatestFrom(removeMode) { _, mode in
        guard let mode = mode else { return }
        switch mode {
        case .Task(var task):
          task.status = .Deleted
          
          // удаляем задачу
          self.services.tasksService.saveTasksToCoreData(tasks: [task])
          
          // убираем алерт
          self.services.tasksService.removeTrigger.accept(nil)
          
          // удаляем пойнт
          self.services.pointService.removePoint(task: task)
          
          // удаляем яйцо
          self.services.birdService.removeEgg(task: task)
          
      
          return
        case .DeletedTasks:
          let tasks = self.services.tasksService.tasks.value.filter{ $0.status == .Deleted }
          self.services.tasksService.removeTasksFromCoreData(tasks: tasks)
          self.services.tasksService.removeTrigger.accept(nil)
        }
      }
    
    // alertCancelButtonClick
    let alertCancelButtonClick = input.alertCancelButtonClick
      .do { _ in
        self.services.tasksService.removeTrigger.accept(nil)
      }
    
    return Output(
      // dataSource
      dataSource: dataSource,
      // selection
      selection: selection,
      // alert
      alertText: alertText,
      alertDeleteButtonClick: alertDeleteButtonClick,
      alertCancelButtonClick: alertCancelButtonClick,
      alertIsHidden:alertIsHidden,
      // back
      backButtonClick: backButtonClick,
      // add
      addTaskButtonClick: addTaskButtonClick,
      addTaskButtonIsHidden: addTaskButtonIsHidden,
      // title
      title: title,
      // remove all
      removeAllDeletedTasksButtonClick: removeAllTasksButtonClick,
      removeAllDeletedTasksButtonIsHidden: removeAllTasksButtonIsHidden
    )
  }
  
  // Helpers
  func viewWillAppear() {
    services.tasksService.reloadDataSource.accept(())
  }
  
  func addTaskButtonIsHidden(with type: ListType) -> Bool {
    if case .Idea = type { return false } else { return true }
  }
  
  func removeAllTasksButtonIsHIdden(with type: ListType) -> Bool {
    if case .Deleted = type { return false } else { return true }
  }
  
  func getTitle(with type: ListType) -> String {
    switch type {
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
  
  func getSceneImage(date: Date) -> UIImage? {
    let hour = Date().hour
    switch hour {
    case 0...5: return UIImage(named: "ночь01")
    case 6...11: return UIImage(named: "утро01")
    case 12...17: return UIImage(named: "день01")
    case 18...23: return UIImage(named: "вечер01")
    default: return nil
    }
  }
}
