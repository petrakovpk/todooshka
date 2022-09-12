//
//  ChangePasswordViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import RxFlow
import RxSwift
import RxCocoa

class ChangePasswordViewModel: Stepper {
  
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let backButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let navigateBack: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let navigateBack = input.backButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.NavigateBack) }
    
    return Output(
      navigateBack: navigateBack
    )
  }
}

