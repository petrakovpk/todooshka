//
//  ShopViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 01.02.2022.
//

import RxFlow
import RxSwift
import RxCocoa

class ShopViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  private let services: AppServices

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }

  struct Output {
    let dataSource: Driver<[ShopSection]>
    let navigateBack: Driver<Void>
    let show: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    // MARK: - INIT
    let birds = services.dataService.birds
    
    // MARK: - NAVIGATE BACK
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.navigateBack) }

    // MARK: - DATASOURCE
    let dataSource = birds
      .map { birds -> [ShopSection] in
        Dictionary(grouping: birds, by: { $0.clade })
          .sorted(by: { $0.key.level < $1.key.level })
          .map { dict in
            ShopSection(
              header: dict.key.text,
              items: dict.value.sorted(by: {
                $0.currency.index <= $1.currency.index
                && $0.price <= $1.price
                && $0.style.index <= $1.style.index
              })
            )
          }
      }
      .asDriver(onErrorJustReturn: [])
    
    // item selected
    let show = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource in
        dataSource[indexPath.section].items[indexPath.item]
      }
      .map { self.steps.accept(AppStep.showBirdIsRequired(bird: $0)) }

    return Output(
      dataSource: dataSource,
      navigateBack: navigateBack,
      show: show
    )
  }
}
