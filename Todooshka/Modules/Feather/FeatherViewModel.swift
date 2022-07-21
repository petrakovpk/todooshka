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
    // button
    let backButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // button
    let backButtonClickHandler: Driver<Void>
    // dataSource
    let dataSource: Driver<[TaskListSectionModel]>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    // tasks
    let tasks = services.tasksService.tasks
      .map {
        $0.filter {
          $0.status == .Completed
        }
        .sorted(by: { $0.closed! > $1.closed! })
      }
      .asDriver(onErrorJustReturn: [])
    
    // dataSource
    let dataSource = tasks
      .map {
        Dictionary
          .init(grouping: $0, by: { $0.closed!.dateString() })
          .map { key, value in
            TaskListSectionModel(header: key, mode: .WithFeather, items: value)
          }
      }
    
    // backButtonClickHandler
    let backButtonClickHandler = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.FeatherIsCompleted) }
    
    return Output(
      backButtonClickHandler: backButtonClickHandler,
      dataSource: dataSource
    )
  }

}


