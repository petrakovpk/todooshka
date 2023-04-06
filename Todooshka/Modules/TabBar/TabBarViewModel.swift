//
//  TabBarViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.07.2021.
//

import RxFlow
import RxSwift
import RxCocoa

class TabBarViewModel: Stepper {
  let steps = PublishRelay<Step>()
  let services: AppServices

  struct Input {
    let createTaskButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let createTask: Driver<Void>
  }

  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let createTask = input.createTaskButtonClickTrigger
      .do { _ in
        self.steps.accept(
          AppStep.openTaskIsRequired(
            task: Task(uuid: UUID(), status: .inProgress),
            isModal: true
          ))
      }

    return Output(
      createTask: createTask
    )
  }
}
