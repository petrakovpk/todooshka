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
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    let backButtonClickHandler = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.FeatherIsCompleted) }
    
    return Output(
      backButtonClickHandler: backButtonClickHandler
    )
  }

}


