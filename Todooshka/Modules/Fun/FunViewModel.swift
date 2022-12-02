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
    let swipeTrigger: Driver<UISwipeGestureRecognizer>
  }

  struct Output {
    let nextContent: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
   
    let nextContent = input.swipeTrigger
      .map { _ in () }

    return Output(
      nextContent: nextContent
    )
  }
}

