//
//  BirdViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class BirdViewModel: Stepper {

  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  var bird: Bird
  
  // MARK: - Transform
  struct Input {
    
    // buttons
    let backButtonClickTrigger: Driver<Void>
    let buyButtonClickTrigger: Driver<Void>
    
    // collectionView
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    
    // title
    let title: Driver<String>
    
    // image
    let image: Driver<UIImage?>
    
    // description
    let description: Driver<String>
    
    // collectionView
    let dataSource: Driver<[TaskTypeListSectionModel]>
    let selection: Driver<TaskType>
    
    // price
    let price: Driver<String>
    
    // buttons
    let backButtonClickHandler: Driver<Void>
    let buyButtonClickHandler: Driver<Void>
    
    // buyButtonIsHidden
    let buyButtonIsHidden: Driver<Bool>
    
  }
  
  //MARK: - Init
  init(bird: Bird, services: AppServices) {
    self.bird = bird
    self.services = services
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    // title
    let title = Driver<String>.of(self.bird.name)
    
    // image
    let image = Driver<UIImage?>.of(self.bird.image)
    
    // buttons
    let backButtonClickHandler = input.backButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.ShopIsCompleted)
      }
    
    let buyButtonClickHandler = input.buyButtonClickTrigger
      .do { _ in
        self.bird.isBought = true
        self.services.birdService.saveBird(bird: self.bird)
      }
    
    // types
    let types = services.typesService.types.asDriver()
    
    // dataSource
    let dataSource = types
      .map { [TaskTypeListSectionModel(header: "", items: $0)] }
      .asDriver(onErrorJustReturn: [])
    
    // selection
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> TaskType in
        return dataSource[indexPath.section].items[indexPath.item] }
    
    // buyButtonIsHidden
    let buyButtonIsHidden = Driver<Bool>.just(self.bird.isBought)
    
    // price
    let price = Driver<String>.of(self.bird.price.string + " " + self.bird.currency.rawValue)
    
    // description
    let description = Driver<String>.of(self.bird.description)

    return Output(
      // title
      title: title,
      // image
      image: image,
      // description
      description: description,
      // dataSource
      dataSource: dataSource,
      selection: selection,
      // price
      price: price,
      // buttons
      backButtonClickHandler: backButtonClickHandler,
      buyButtonClickHandler: buyButtonClickHandler,
      // buyButtonIsHidden
      buyButtonIsHidden: buyButtonIsHidden
    )
  }
}
