//
//  ThemeViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.11.2022.
//

import RxCocoa
import RxFlow
import RxSwift

class ThemeViewModel: Stepper {
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices

  // theme
  let themeUID: String

  struct Input {
    let backButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let name: Driver<String>
    let navigateBack: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, themeUID: String) {
    self.services = services
    self.themeUID = themeUID
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    // theme
    let theme = services
      .dataService
      .themes
      .compactMap { $0.first { $0.UID == self.themeUID } }

    let name = theme.map { $0.name }

    // buttons
    let navigateBack = input
      .backButtonClickTrigger
      .map { self.steps.accept(AppStep.navigateBack) }

    return Output(
      name: name,
      navigateBack: navigateBack
    )
  }
}
