//
//  ScoreViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.02.2022.
//

import RxFlow
import RxSwift
import RxCocoa

class ScoreViewModel: Stepper {
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices

  // MARK: - Transform
  struct Input {
    // button
    let backButtonClickHandler: Driver<Void>
    let buyButtonClickTrigger: Driver<Void>
  }

  struct Output {
    // button
    let backButtonClickHandler: Driver<Void>
    let buyButtonClickHandler: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let backButtonClickHandler = input.backButtonClickHandler
      .map { self.steps.accept(AppStep.navigateBack) }

    let buyButtonClickHandler = input.buyButtonClickTrigger

    return Output(
      backButtonClickHandler: backButtonClickHandler,
      buyButtonClickHandler: buyButtonClickHandler
    )
  }
}
