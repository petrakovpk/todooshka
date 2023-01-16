//
//  ThemeStepViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class ChallengeViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  var themeStep: ThemeStep
  let openViewControllerMode: OpenViewControllerMode

  struct Input {
    let backButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let navigateBack: Driver<Void>
    let openViewControllerMode: Driver<OpenViewControllerMode>
  }

  // MARK: - Init
  init(services: AppServices, themeStep: ThemeStep, openViewControllerMode: OpenViewControllerMode) {
    self.openViewControllerMode = openViewControllerMode
    self.services = services
    self.themeStep = themeStep
  }

  func transform(input: Input) -> Output {
    let openViewControllerMode = Driver<OpenViewControllerMode>
      .just(self.openViewControllerMode)
    
    // back
    let navigateBack = input
      .backButtonClickTrigger
      .map { self.steps.accept(AppStep.navigateBack) }

    return Output(
      navigateBack: navigateBack,
      openViewControllerMode: openViewControllerMode
    )
  }
}

