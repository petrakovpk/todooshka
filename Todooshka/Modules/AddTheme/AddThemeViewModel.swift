//
//  AddThemeViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 10.11.2022.
//

import RxCocoa
import RxFlow
import RxSwift

class AddThemeViewModel: Stepper {
  
  let steps = PublishRelay<Step>()
  let services: AppServices

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }

  struct Output {
    let dataSource: Driver<[ThemeDaySection]>
    let navigateBack: Driver<Void>
    let openThemeDay: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
 
    // dataSource
    let dataSource = Driver<[ThemeDaySection]>.just(
      [
        ThemeDaySection(header: "1-я неделя", items: [
          ThemeDay(UID: UUID().uuidString, goal: "monday", weekDay: .monday),
          ThemeDay(UID: UUID().uuidString, goal: "tuesday", weekDay: .tuesday),
          ThemeDay(UID: UUID().uuidString, goal: "wednesday", weekDay: .wednesday),
          ThemeDay(UID: UUID().uuidString, goal: "thursday", weekDay: .thursday),
          ThemeDay(UID: UUID().uuidString, goal: "friday", weekDay: .friday),
          ThemeDay(UID: UUID().uuidString, goal: "saturday", weekDay: .saturday),
          ThemeDay(UID: UUID().uuidString, goal: "sunday", weekDay: .sunday)
        ]),
        ThemeDaySection(header: "2-я неделя", items: [
          ThemeDay(UID: UUID().uuidString, goal: "monday", weekDay: .monday),
          ThemeDay(UID: UUID().uuidString, goal: "tuesday", weekDay: .tuesday),
          ThemeDay(UID: UUID().uuidString, goal: "wednesday", weekDay: .wednesday),
          ThemeDay(UID: UUID().uuidString, goal: "thursday", weekDay: .thursday),
          ThemeDay(UID: UUID().uuidString, goal: "friday", weekDay: .friday),
          ThemeDay(UID: UUID().uuidString, goal: "saturday", weekDay: .saturday),
          ThemeDay(UID: UUID().uuidString, goal: "sunday", weekDay: .sunday)
        ]),
        ThemeDaySection(header: "3-я неделя", items: [
          ThemeDay(UID: UUID().uuidString, goal: "monday", weekDay: .monday),
          ThemeDay(UID: UUID().uuidString, goal: "tuesday", weekDay: .tuesday),
          ThemeDay(UID: UUID().uuidString, goal: "wednesday", weekDay: .wednesday),
          ThemeDay(UID: UUID().uuidString, goal: "thursday", weekDay: .thursday),
          ThemeDay(UID: UUID().uuidString, goal: "friday", weekDay: .friday),
          ThemeDay(UID: UUID().uuidString, goal: "saturday", weekDay: .saturday),
          ThemeDay(UID: UUID().uuidString, goal: "sunday", weekDay: .sunday)
        ])
      ]
    )
    
    let themeDaySelected = input
      .selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> ThemeDay in
        dataSource[indexPath.section].items[indexPath.item]
      }
    
    let openThemeDay = themeDaySelected
      .map { self.steps.accept(AppStep.themeDayIsRequired(themeDayUID: $0.UID)) }
    
    // back
    let navigateBack = input
      .backButtonClickTrigger
      .map { self.steps.accept(AppStep.showThemeIsCompleted) }

    return Output(
      dataSource: dataSource,
      navigateBack: navigateBack,
      openThemeDay: openThemeDay
    )
  }
}

