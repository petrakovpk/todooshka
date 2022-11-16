//
//  ThemeViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.11.2022.
//

import RxCocoa
import RxFlow
import RxSwift

enum OpenViewControllerMode {
  case edit
  case view
}

class ThemeViewModel: Stepper {
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices

  // theme
  let themeUID: String
  let openViewControllerMode: OpenViewControllerMode

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }

  struct Output {
    let dataSource: Driver<[ThemeDaySection]>
    let name: Driver<String>
    let navigateBack: Driver<Void>
    let openThemeDay: Driver<Void>
    let openViewControllerMode: Driver<OpenViewControllerMode>
  }

  // MARK: - Init
  init(services: AppServices, themeUID: String, openViewControllerMode: OpenViewControllerMode) {
    self.openViewControllerMode = openViewControllerMode
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
    
    // dataSource
    let dataSource = Driver<[ThemeDaySection]>.just(
      [
        ThemeDaySection(header: "1-й круг", items: [
          ThemeDay(UID: UUID().uuidString, goal: "monday", weekDay: .first),
          ThemeDay(UID: UUID().uuidString, goal: "tuesday", weekDay: .second),
          ThemeDay(UID: UUID().uuidString, goal: "wednesday", weekDay: .third),
          ThemeDay(UID: UUID().uuidString, goal: "thursday", weekDay: .fourth),
          ThemeDay(UID: UUID().uuidString, goal: "friday", weekDay: .fifth),
          ThemeDay(UID: UUID().uuidString, goal: "saturday", weekDay: .sixth),
          ThemeDay(UID: UUID().uuidString, goal: "sunday", weekDay: .seventh)
        ]),
        ThemeDaySection(header: "2-й круг", items: [
          ThemeDay(UID: UUID().uuidString, goal: "monday", weekDay: .first),
          ThemeDay(UID: UUID().uuidString, goal: "tuesday", weekDay: .second),
          ThemeDay(UID: UUID().uuidString, goal: "wednesday", weekDay: .third),
          ThemeDay(UID: UUID().uuidString, goal: "thursday", weekDay: .fourth),
          ThemeDay(UID: UUID().uuidString, goal: "friday", weekDay: .fifth),
          ThemeDay(UID: UUID().uuidString, goal: "saturday", weekDay: .sixth),
          ThemeDay(UID: UUID().uuidString, goal: "sunday", weekDay: .seventh)
        ]),
        ThemeDaySection(header: "3-й круг", items: [
          ThemeDay(UID: UUID().uuidString, goal: "monday", weekDay: .first),
          ThemeDay(UID: UUID().uuidString, goal: "tuesday", weekDay: .second),
          ThemeDay(UID: UUID().uuidString, goal: "wednesday", weekDay: .third),
          ThemeDay(UID: UUID().uuidString, goal: "thursday", weekDay: .fourth),
          ThemeDay(UID: UUID().uuidString, goal: "friday", weekDay: .fifth),
          ThemeDay(UID: UUID().uuidString, goal: "saturday", weekDay: .sixth),
          ThemeDay(UID: UUID().uuidString, goal: "sunday", weekDay: .seventh)
        ])
      ]
    )
    
    let themeDaySelected = input
      .selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> ThemeDay in
        dataSource[indexPath.section].items[indexPath.item]
      }
    
    let openViewControllerMode = Driver<OpenViewControllerMode>
      .just(self.openViewControllerMode)
    
    let openThemeDay = themeDaySelected
      .withLatestFrom(openViewControllerMode) { themeDay, openViewControllerMode in
        self.steps.accept(
          AppStep.themeDayIsRequired(
            themeDayUID: themeDay.UID,
            openViewControllerMode: openViewControllerMode))
      }
    
    // buttons
    let navigateBack = input
      .backButtonClickTrigger
      .map { self.steps.accept( AppStep.openThemeIsCompleted ) }

    return Output(
      dataSource: dataSource,
      name: name,
      navigateBack: navigateBack,
      openThemeDay: openThemeDay,
      openViewControllerMode: openViewControllerMode
    )
  }
}
