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
    let addThemeButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }

  struct Output {
//    let addTheme: Driver<Void>
//    let dataSource: Driver<[ThemeSection]>
//    let openTheme: Driver<Theme>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
//    let themes = services.dataService.themes
//
//    let dataSource = themes
//      .map { themes -> [ThemeSection] in
//        [
//          ThemeSection(
//            header: "Мое",
//            items: themes.map { theme -> ThemeItem in
//                .theme(theme: theme)
//            }
//          )
//        ]
//      }
//
//    let itemSelected = input.selection
//      .withLatestFrom(dataSource) { indexPath, dataSource -> ThemeItem in
//        dataSource[indexPath.section].items[indexPath.item]
//      }
//
//    let themeSelected = itemSelected
//      .compactMap { item -> Theme? in
//        guard case .theme(let theme) = item else { return nil }
//        return theme
//      }
//
//    let addTheme = input.addThemeButtonClickTrigger
//      .do { _ in
//        self.steps.accept(AppStep.themeIsRequired(theme: Theme.empty))
//      }
//
//    let openTheme = themeSelected
//      .do {
//        self.steps.accept(AppStep.themeIsRequired(theme: $0))
//      }

    return Output(
//      addTheme: addTheme,
//      dataSource: dataSource,
//      openTheme: openTheme
    )
  }
}
