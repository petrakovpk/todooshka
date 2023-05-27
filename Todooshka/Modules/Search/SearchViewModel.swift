//
//  SearchViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 24.05.2023.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class SearchViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    // serach buttons
    let questsButtonClickTrigger: Driver<Void>
    let usersButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // back
    let navigateBack: Driver<AppStep>
    // scrollToPage
    let scrollToPage: Driver<Int>
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
    
    let scrollToFirstPage = input.questsButtonClickTrigger.map { 0 }
    let scrollToSecondPage = input.usersButtonClickTrigger.map { 1 }
    
    let scrollToPage = Driver
      .of(scrollToFirstPage, scrollToSecondPage)
      .merge()
   
    return Output(
      navigateBack: navigateBack,
      scrollToPage: scrollToPage
    )
  }
}

