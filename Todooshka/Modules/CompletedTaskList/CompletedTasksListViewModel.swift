//
//  CompletedTasksListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Firebase

class CompletedTasksListViewModel: Stepper {
  
  let steps = PublishRelay<Step>()
  let dataSource = BehaviorRelay<[TaskListSectionModel]>(value: [])
  let disposeBag = DisposeBag()
  let services: AppServices
  let formatter = DateFormatter()
  let date: Date
  let taskListHeaderOutput = BehaviorRelay<String>(value: "")
  let showAlert = BehaviorRelay<Bool>(value: false)
  
  //MARK: - Init
  init(services: AppServices, date: Date) {
    self.services = services
    self.date = date
    
    formatter.dateFormat = "d MMMM yyyy"
    formatter.timeZone =  TimeZone(abbreviation: "UTC")
    formatter.locale = Locale(identifier: "ru")
    
    services.coreDataService.tasks.map({$0.filter{ task in
      guard let completedDate = task.closedDate else { return false }
      return task.status == .completed && completedDate.beginning(of: .day) == date.beginning(of: .day)
    }}).bind { [weak self] tasks in
      guard let self = self else { return }
      
      let tasksDict = Dictionary(grouping: tasks, by: {$0.taskType?.text ?? "" }).sorted{ $0.key > $1.key }
      
      var models: [TaskListSectionModel] = []
      
      for taskDict in tasksDict {
        models.append(TaskListSectionModel(header: taskDict.key, items: taskDict.value))
      }
      self.dataSource.accept(models)
      
    }.disposed(by: disposeBag)
    
    services.coreDataService.taskRemovingIsRequired.bind{ [weak self] task in
      guard let self = self else { return }
      if let task = task, task.status == .completed {
        self.showAlert.accept(true)
      } else {
        self.showAlert.accept(false)
      }
    }.disposed(by: disposeBag)
  }
  
  //MARK: - Handlers
  func openTask(indexPath: IndexPath) {
    let task = dataSource.value[indexPath.section].items[indexPath.item]
    steps.accept(AppStep.showTaskIsRequired(task: task))
  }
  
  func alertCancelButtonClicked() {
    services.coreDataService.taskRemovingIsRequired.accept(nil)
  }
  
  func alertDeleteButtonClicked() {
    if let task = services.coreDataService.taskRemovingIsRequired.value {
      task.status = .deleted
      services.coreDataService.saveTasksToCoreData(tasks: [task]) { error in
        if let error = error  {
          print(error.localizedDescription)
          return
        }
        self.services.coreDataService.taskRemovingIsRequired.accept(nil)
      }
    }
  }
  
  func rightBarButtonAddItemClick() {
    steps.accept(AppStep.createTaskIsRequired(status: .completed, createdDate: date) )
  }
  
  func leftBarButtonBackItemClick() {
    steps.accept(AppStep.completedTaskListIsCompleted)
  }
  
}

