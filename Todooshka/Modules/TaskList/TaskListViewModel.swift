//
//  TasksViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Firebase

class TaskListViewModel: Stepper {
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  struct Input {
    let ideaButtonClickTrigger: Driver<Void>
    let overdueButtonClickTrigger: Driver<Void>
    let sortedByButtoncLickTrigger: Driver<Void>
    let deleteAlertButtonClickTrigger: Driver<Void>
    let cancelAlerrtButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let ideaButtonClick: Driver<Void>
    let overdueButtonClick: Driver<Void>
    let sortedByButtoncLick: Driver<Void>
    let deleteAlertButtonClick: Driver<Void>
    let cancelAlerrtButtonClick: Driver<Void>
    
    let openTask: Driver<Void>
    let dataSource: Driver<[TaskListSectionModel]>
    let tasksCount: Driver<Int>
    let overdueButtonIsHidden: Driver<Bool>
    let alertIsHidden: Driver<Bool>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let ideaButtonClick = input.ideaButtonClickTrigger
      .map{ self.steps.accept(AppStep.ideaBoxTaskListIsRequired) }
    
    let overdueButtonClick = input.overdueButtonClickTrigger
      .map{ self.steps.accept(AppStep.overdueTaskListIsRequired) }
    
    let sortedByButtoncLick = input.sortedByButtoncLickTrigger
    
    let deleteAlertButtonClick = input.deleteAlertButtonClickTrigger
      .map { _ in
        if let task = self.services.coreDataService.taskRemovingIsRequired.value {
        task.status = .deleted
        self.services.coreDataService.saveTasksToCoreData(tasks: [task]) { error in
          if let error = error  {
            print(error.localizedDescription)
            return
          }
          self.services.coreDataService.taskRemovingIsRequired.accept(nil)
        }
      }
    }
    
    let cancelAlertButtonClick = input.cancelAlerrtButtonClickTrigger
      .map{ self.services.coreDataService.taskRemovingIsRequired.accept(nil) }
    
    let dataSource = services.coreDataService.tasks
      .withLatestFrom(services.coreDataService.reloadTasksDataSorce) { (tasks, _) -> [TaskListSectionModel] in
        let tasks = tasks.filter{ $0.isCurrent == true }
        return [TaskListSectionModel(header: "", items: tasks)] }
      .asDriver(onErrorJustReturn: [])
    
    let tasksCount = dataSource
      .map{ return $0.first?.items.count ?? 0 }
    
    let overdueButtonIsHidden = services.coreDataService.tasks
      .map{ tasks -> Bool in
        let tasks = tasks.filter{ $0.isOverdued == true }
        return tasks.count == 0 }
      .asDriver(onErrorJustReturn: false)
    
    let alertIsHidden = services.coreDataService.taskRemovingIsRequired
      .map{ return $0 == nil }
      .asDriver(onErrorJustReturn: false)
    
    let openTask = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource in
      let task = dataSource[indexPath.section].items[indexPath.item]
      self.steps.accept(AppStep.showTaskIsRequired(task: task)) }
    
    return Output(
      ideaButtonClick: ideaButtonClick,
      overdueButtonClick: overdueButtonClick,
      sortedByButtoncLick: sortedByButtoncLick,
      deleteAlertButtonClick: deleteAlertButtonClick,
      cancelAlerrtButtonClick: cancelAlertButtonClick,
      openTask: openTask,
      dataSource: dataSource,
      tasksCount: tasksCount,
      overdueButtonIsHidden: overdueButtonIsHidden,
      alertIsHidden: alertIsHidden
    )
  }
  
}
