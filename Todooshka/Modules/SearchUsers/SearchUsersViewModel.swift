//
//  SearchUsersViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 24.05.2023.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class SearchUsersViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let backButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // back
    let navigateBack: Driver<AppStep>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    
    let navigateBack = input.backButtonClickTrigger
      .map { _ -> AppStep in
          .navigateBack
      }
      .do { step in
        self.steps.accept(step)
      }
   
    return Output(
      navigateBack: navigateBack
    )
  }
}


