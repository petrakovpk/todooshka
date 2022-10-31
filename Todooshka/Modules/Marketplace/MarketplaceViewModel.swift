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
 //   let openTheme: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    let dataSource = Driver<[ThemeSection]>.of(
      [
        ThemeSection(
          header: "Привычки",
          items: [
            ThemeItem(theme: Theme(UID: UUID().uuidString, name: "Бросаем курить")),
            ThemeItem(theme: Theme(UID: UUID().uuidString, name: "Начинаем отжиматься")),
            ThemeItem(theme: Theme(UID: UUID().uuidString, name: "Читаем по одной книге в неделю"))
          ]
        )
      ]
    )
    
    return Output(
      dataSource: dataSource
    )
  }
}

