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
            header: "Рекомендуемое",
            items: [
              ThemeItem(theme: themes[0]),
              ThemeItem(theme: themes[1]),
              ThemeItem(theme: themes[2])
            ]
          ),
          ThemeSection(
            header: "Привычки",
            items: [
              ThemeItem(theme: themes[3]),
              ThemeItem(theme: themes[4]),
              ThemeItem(theme: themes[5])
            ]
          )
        ]
      }

    let openTheme = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> Theme in
        dataSource[indexPath.section].items[indexPath.item].theme
      }
      .map { self.steps.accept(AppStep.showThemeIsRequired(themeUID: $0.UID)) }

    return Output(
      dataSource: dataSource,
      openTheme: openTheme
    )
  }
}
