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
  
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  struct Input {
    // buttons
    let backButtonClickTrigger: Driver<Void>
    // collection view
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    // buttons
    let backButtonClickHandler: Driver<Void>
    // collectionView
    let itemSelected: Driver<Void>
    let dataSource: Driver<[ShopSectionModel]>
  }
  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    // buttons
    let backButtonClickHandler = input.backButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.ShopIsCompleted)
      }
    
    // birds
    let birds = services.birdService.birds
      .asDriver()
    
    // dataSource
    let dataSource = birds
      .map { birds -> [ShopSectionModel] in
        var result: [ShopSectionModel] = []
        let birdsGroupingByClade = Dictionary(grouping: birds, by: { $0.clade })
          .sorted(by: { $0.key.index < $1.key.index })
        
        for birds in birdsGroupingByClade {
          let header = birds.key.rawValue
          let birds = birds.value.sorted(by: { $0.currency.index < $1.currency.index && $0.price < $1.price })
          result.append(ShopSectionModel(header: header, items: birds))
        }
        
        return result
      }.asDriver(onErrorJustReturn: [])
    
    // item selected
    let itemSelected = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource in
        return dataSource[indexPath.section].items[indexPath.item]
      }.map { bird in
        self.steps.accept(AppStep.ShowBirdIsRequired(bird: bird))
      }
    
    return Output(
      // buttons
      backButtonClickHandler: backButtonClickHandler,
      // dataSource
      itemSelected: itemSelected,
      dataSource: dataSource
    )
  }
  
}
