//
//  MarketplaceViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class MarketplaceViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let selection: Driver<IndexPath>
  }

  struct Output {
    let addTheme: Driver<Void>
    let dataSource: Driver<[ThemeSection]>
    let openTheme: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let themes = services.dataService.themes

    let dataSource = themes
      .map { themes -> [ThemeSection] in
        [
          ThemeSection(
            header: "Мои темы",
            items: [
              .theme(theme: themes[0]),
              .plusButton
            ]
          ),
          ThemeSection(
            header: "Рекомендуемое",
            items: [
              .theme(theme: themes[1]),
              .theme(theme: themes[2]),
              .theme(theme: themes[3])
            ]
          ),
          ThemeSection(
            header: "Привычки",
            items: [
              .theme(theme: themes[4]),
              .theme(theme: themes[5]),
              .theme(theme: themes[6])
            ]
          )
        ]
      }

    let itemSelected = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> ThemeItem in
        dataSource[indexPath.section].items[indexPath.item]
      }
    
    let addTheme = itemSelected
      .compactMap { item -> Void? in
        guard case .plusButton = item else { return nil }
        return ()
      }
      .map { self.steps.accept(AppStep.addThemeIsRequired) }
    
    let openTheme = itemSelected
      .compactMap { item -> Theme? in
        guard case .theme(let theme) = item else { return nil }
        return theme
      }
      .map { self.steps.accept(AppStep.showThemeIsRequired(themeUID: $0.UID)) }

    return Output(
      addTheme: addTheme,
      dataSource: dataSource,
      openTheme: openTheme
    )
  }
}
