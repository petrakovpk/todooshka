//
//  WorklplaceViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.01.2023.
//

import RxFlow
import RxSwift
import RxCocoa

class WorklplaceViewModel: Stepper {
  
  public let steps = PublishRelay<Step>()
 
  private let services: AppServices

  struct Input {

  }

  struct Output {
    let scrollToPage: Driver<Int>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let scrollToPage = services.preferencesService
      .workplaceScrollToPageIndex
      .asDriverOnErrorJustComplete()
    
    return Output(
      scrollToPage: scrollToPage
    )
  }

}

