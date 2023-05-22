//
//  TabBarViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.07.2021.
//

import RxFlow
import RxSwift
import RxCocoa

class TabBarViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices

  struct Input {
    let tabBarAddButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let showAddTabBarPresentation: Driver<AppStep>
  }

  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let showAddTabBarPresentation = input.tabBarAddButtonClickTrigger
      .map { _ -> Task in
        Task(uuid: UUID(), status: .draft)
      }
      .map { task -> AppStep in
          .addTabBarPresentationIsRequired
      }
      .do { step in
        self.steps.accept(step)
      }

    return Output(
      showAddTabBarPresentation: showAddTabBarPresentation
    )
  }
}
