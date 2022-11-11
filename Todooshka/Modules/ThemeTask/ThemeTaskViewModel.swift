//
//  ThemeTaskViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class ThemeTaskViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  struct Input {
    let backButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let navigateBack: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, themeDayUID: String) {
    self.services = services
    self.themeDayUID = themeDayUID
  }

  func transform(input: Input) -> Output {
    
    // back
    let navigateBack = input
      .backButtonClickTrigger
      .map { self.steps.accept(AppStep.navigateBack) }

    return Output(
      navigateBack: navigateBack
    )
  }
}


