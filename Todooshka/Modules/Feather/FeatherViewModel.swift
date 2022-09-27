//
//  FeatherViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 20.06.2022.
//

import RxFlow
import RxSwift
import RxCocoa

class FeatherViewModel: Stepper {

  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  // MARK: - Transform
  struct Input {
    let backButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let dataSource: Driver<[TaskListSection]>
    let navigateBack: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    // tasks
    let tasks = services.dataService
      .tasks
      .map {
        $0.filter {
          $0.status == .Completed ? true : false
        }
        .sorted(by: { $0.closed! > $1.closed! })
      }
      .asDriver(onErrorJustReturn: [])
    
    let kindsOfTask = services.dataService.kindsOfTask.asDriver()
    
    let taskListSectionItems = Driver<[TaskListSectionItem]>
      .combineLatest(tasks,kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
        tasks.map { task in
          TaskListSectionItem(
            task: task,
            kindOfTask: kindsOfTask.first(where: { $0.UID == task.kindOfTaskUID }) ?? KindOfTask.Standart.Simple
          )
        }
      }
    

    // dataSource
    let dataSource = taskListSectionItems
      .map {
        Dictionary
          .init(grouping: $0, by: { $0.task.closed?.startOfDay ?? Date().startOfDay })
          .sorted(by: { $0.key > $1.key })
          .map { key, value in
            TaskListSection(header: key.string(withFormat: "dd MMM yyyy") , mode: .WithFeather, items: value)
          }
      }
    
    // backButtonClickHandler
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.NavigateBack) }
    
    return Output(
      dataSource: dataSource,
      navigateBack: navigateBack
    )
  }

}


