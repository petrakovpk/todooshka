//
//  UserListViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import RxCocoa
import RxFlow
import RxSwift

class UserListViewModel: Stepper {
  public let steps = PublishRelay<Step>()
 
  private let services: AppServices

  struct Input {
    // BACK
    let backButtonClickTrigger: Driver<Void>
   
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
   

    let navigateBack = input.backButtonClickTrigger
      .map { _ in AppStep.navigateBack }
      .do { step in self.steps.accept(step) }
    
    return Output(
      // header
      navigateBack: navigateBack
    )
  }
}

