//
//  DayTaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import RxFlow
import RxSwift
import RxCocoa

class DayTaskListViewModel: Stepper {
  
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let disposeBag = DisposeBag()
  let services: AppServices
  let date: Date
  
  let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM yyyy"
    formatter.timeZone =  TimeZone(abbreviation: "UTC")
    formatter.locale = Locale(identifier: "ru")
    return formatter
  }()
  
  struct Input {
    let addTaskButtonClickTrigger: Driver<Void>
    let backTaskButtonClickTrigger: Driver<Void>
    
    let deleteAlertButtonClickTrigger: Driver<Void>
    let cancelAlertButtonClickTrigger: Driver<Void>
    
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let openTask: Driver<Void>
    
    let dataSource: Driver<[TaskListSectionModel]>
    let alertIsHidden: Driver<Bool>
    
    let addTaskButtonClick: Driver<Void>
    let backTaskButtonClick: Driver<Void>
    let deleteAlertButtonClick: Driver<Void>
    let cancelAlertButtonClick: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices, date: Date) {
    self.services = services
    self.date = date
  }
  
  func transform(input: Input) -> Output {
    
    let dataSource = services.tasksService.tasks
      .map { tasks -> [TaskListSectionModel] in
        
        let tasks = tasks
          .filter { self.date.beginning(of: .day) ==
            ( self.date <= Date() ? $0.closedDate : $0.plannedDate)?.beginning(of: .day)
          }
        
        let tasksDict = Dictionary(grouping: tasks, by: { $0.type?.text ?? "Нет типа" }).sorted{ $0.key > $1.key }
        var models: [TaskListSectionModel] = []
        for taskDict in tasksDict {
          models.append(TaskListSectionModel(header: taskDict.key, items: taskDict.value.sorted{ $0.text < $1.text }))
        }
        return models
      }.asDriver(onErrorJustReturn: [])
    
    let openTask = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource in
        let task = dataSource[indexPath.section].items[indexPath.item]
        self.steps.accept(AppStep.showTaskIsRequired(task: task))
      }
    
    let alertIsHidden = services.tasksService.taskRemovingIsRequired
      .map { return $0 == nil }
      .asDriver(onErrorJustReturn: false)
    
    let addTaskButtonClick = input.addTaskButtonClickTrigger
      .do( onNext: { self.steps.accept(AppStep.createTaskIsRequired(status: .completed, createdDate: self.date)) })
        
        let backTaskButtonClick = input.backTaskButtonClickTrigger
        .do( onNext: { self.steps.accept(AppStep.completedTaskListIsCompleted) })
          
          let deleteAlertButtonClick = input.deleteAlertButtonClickTrigger
          .do { _ in
            if let task = self.services.tasksService.taskRemovingIsRequired.value {
              task.status = .deleted
              self.services.tasksService.updateTasks(tasks: [task]) { error in
                if let error = error  {
                  print(error.localizedDescription)
                  return
                }
                self.services.tasksService.taskRemovingIsRequired.accept(nil)
              }
            }}
    
    let cancelAlertButtonClick = input.cancelAlertButtonClickTrigger
      .do( onNext: { self.services.tasksService.taskRemovingIsRequired.accept(nil) })
        
    return Output(
      openTask: openTask,
      dataSource: dataSource,
      alertIsHidden: alertIsHidden,
      addTaskButtonClick: addTaskButtonClick,
      backTaskButtonClick: backTaskButtonClick,
      deleteAlertButtonClick: deleteAlertButtonClick,
      cancelAlertButtonClick: cancelAlertButtonClick
    )}

}

