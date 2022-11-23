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
  
  let themeTaskUID: String
  let openViewControllerMode: OpenViewControllerMode
  
  struct Input {
    let backButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let navigateBack: Driver<Void>
    let openViewControllerMode: Driver<OpenViewControllerMode>
  }

  // MARK: - Init
  init(services: AppServices, themeTaskUID: String, openViewControllerMode: OpenViewControllerMode) {
    self.services = services
    self.themeTaskUID = themeTaskUID
    self.openViewControllerMode = openViewControllerMode
  }

  func transform(input: Input) -> Output {
    
    // back
    let navigateBack = input
      .backButtonClickTrigger
      .map { self.steps.accept(AppStep.navigateBack) }
    
    // openViewControllerMode
    let openViewControllerMode = Driver<OpenViewControllerMode>
      .just(self.openViewControllerMode)

    return Output(
      navigateBack: navigateBack,
      openViewControllerMode: openViewControllerMode
    )
  }
}


