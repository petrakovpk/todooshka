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
  let dataSource = BehaviorRelay<[TaskListSectionModel]>(value: [])
  let overdueButtonIsHidden = BehaviorRelay<Bool>(value: true)
  let headerText = BehaviorRelay<String>(value: "")
  let disposeBag = DisposeBag()
  let services: AppServices
  let statusBarStyleRelay = BehaviorRelay<UIStatusBarStyle>(value: .darkContent)

  //MARK: - Init
  init(services: AppServices) {
    self.services = services
    
    services.coreDataService.tasks.map({$0.filter{$0.isCurrent == true}}).bind { [weak self] tasks in
      guard let self = self else { return }
      
      self.dataSource.accept([TaskListSectionModel(header: "", items: tasks) ])
      
    }.disposed(by: self.disposeBag)
    
    services.coreDataService.tasks
      .map({$0.filter{$0.isOverdued == true}})
      .bind { [weak self] tasks in
        guard let self = self else { return }
        self.overdueButtonIsHidden.accept(tasks.count == 0)
      }.disposed(by: self.disposeBag)
    
  }
  
  func openTask(indexPath: IndexPath) {
    let task = dataSource.value[indexPath.section].items[indexPath.item]
    steps.accept(AppStep.showTaskIsRequired(task: task))
  }
  
  func navigateToOverdueTaskList() {
    steps.accept(AppStep.overdueTaskListIsRequired)
  }
  
  func sortedByButtonClicked() {
    if UserDefaults.standard.bool(forKey: "isSortedByType") {
      UserDefaults.standard.setValue(false, forKey: "isSortedByType")
      var tasks = services.coreDataService.tasks.value
      tasks.sort{ $0.createdTimeIntervalSince1970 < $1.createdTimeIntervalSince1970 }
      services.coreDataService.tasks.accept(tasks)
    } else {
      UserDefaults.standard.setValue(true, forKey: "isSortedByType")
      var tasks = services.coreDataService.tasks.value
      tasks.sort{ ($0.taskType!.orderNumber, $0.createdTimeIntervalSince1970) < ($1.taskType!.orderNumber, $1.createdTimeIntervalSince1970) }
      services.coreDataService.tasks.accept(tasks)
    }
  }
  
  func removeTask(task: Task) {
    services.networkDatabaseService.removeTaskFromDatabase(task: task) { error, ref in
      if let error = error {
        print(error.localizedDescription)
        return
      }
    }
  }
}
