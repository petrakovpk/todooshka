//
//  FunViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 18.11.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class FunViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  struct Input {
    let authorImageClickTrigger: Driver<Void>
    let authorNameClickTrigger: Driver<Void>
    let taskTextClickTrigger: Driver<Void>
    let badButtonClickTrigger: Driver<Void>
    let goodButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let openAuthorPage: Driver<Void>
    let openTaskPage: Driver<Void>
    let getNextTask: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {

    let openAuthorPage = Driver.of(
      input.authorNameClickTrigger,
      input.authorImageClickTrigger
    )
      .merge()
    
    let openTaskPage = input.taskTextClickTrigger
    
    let getNextTask = Driver.of(
      input.badButtonClickTrigger,
      input.goodButtonClickTrigger
    )
      .merge()
    
    return Output(
      openAuthorPage: openAuthorPage,
      openTaskPage: openTaskPage,
      getNextTask: getNextTask
    )
  }
}

