//
//  FeedViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 18.11.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class FeedViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
  
  }

  struct Output {
   
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
   

    return Output(
      
    )
  }
}

