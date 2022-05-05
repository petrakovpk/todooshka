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
    let alertCancelButtonClick: Driver<Void>
    let alertBuyButtonClick: Driver<Void>
    
    // collectionView
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    
    // Properties
    
    // title
    let title: Driver<String>
    // image
    let image: Driver<UIImage?>
    // description
    let description: Driver<String>
    // collectionView
    let dataSource: Driver<[TypeSmallCollectionViewCellSectionModel]>
    // price
    let price: Driver<String>
    // buyButtonIsHidden
    let buyButtonIsHidden: Driver<Bool>
    // isBoughtLabel
    let isBoughtLabel: Driver<Bool>
    // buyAlertViewIsHidden
    let buyAlertViewIsHidden: Driver<Bool>
    // eggImageView
    let eggImageView: Driver<UIImage?>
    // birdImageView
    let birdImageView: Driver<UIImage?>
    // buyButtonIsEnabled
    let buyButtonIsEnabled: Driver<Bool>
    // labelText
    let labelText: Driver<String>
    
    // Actions
    
    // back
    let back: Driver<Void>
    // selection
    let selection: Driver<TaskType>
    // buy
    let buy: Driver<Void>
    
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
    let image = Driver<UIImage?>.of(self.bird.getImageForState(state: .Normal))
    
    // description
    let description = Driver<String>.of(self.bird.description)
    
    // price
    let price = Driver<String>.of(self.bird.price.string)
    
    // types
    let types = services.typesService.types.asDriver()
    
    // bird
    let bird = services.birdService.birds
      .map{ $0.first { $0.UID == self.bird.UID } ?? self.bird }
      .asDriver(onErrorJustReturn: self.bird)
        
    // dataSource
    let dataSource = Driver.combineLatest(bird, types) { bird, types -> [TypeSmallCollectionViewCellSectionModel] in
        var items: [TypeSmallCollectionViewCellSectionModelItem] = []
        for type in types {
          items.append(TypeSmallCollectionViewCellSectionModelItem(type: type, isSelected: type.birdUID == bird.UID, isEnabled: bird.isBought))
        }
        return [TypeSmallCollectionViewCellSectionModel(header: "", items: items)]
      }
      .asDriver(onErrorJustReturn: [])

    // buyButtonIsHidden
    let buyButtonIsHidden = bird.map{ $0.isBought }
    
    // eggImageView
    let eggImageView = Driver<UIImage?>.of(self.bird.clade.image)
    
    // birdImageView
    let birdImageView = Driver<UIImage?>.of(self.bird.getImageForState(state: .Normal))
    
    // isBoughtLabel
    let isBoughtLabel = bird.map{ $0.isBought == false }
    
    // back
    let back = input.backButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.ShopIsCompleted)
      }
    
    // selection
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> TaskType in
        return dataSource[indexPath.section].items[indexPath.item].type }
      .withLatestFrom(bird) { type, bird -> TaskType in
        guard bird.isBought else { return type }
        var type = type
        type.birdUID = (type.birdUID == self.bird.UID) ? nil : self.bird.UID
        self.services.typesService.saveTypesToCoreData(types: [type])
        return type
      }
    
    // buyAlertViewIsHidden
    let buyAlertViewIsHidden = Driver
      .of(
        input.buyButtonClickTrigger.map { false }, 
        input.alertCancelButtonClick.map { true },
        input.alertBuyButtonClick.map { true }
      )
      .merge()
    
    let points = services.pointService.points
      .map { $0.filter{ $0.currency == self.bird.currency } }
      .asDriver(onErrorJustReturn: [])
    
    let possibilities = bird.withLatestFrom(points) { $1.count - $0.price }
    
    let buyButtonIsEnabled = possibilities.map{ $0 >= 0 ? true : false }
    
    let labelText = possibilities.map{ $0 >= 0 ? "Можете купить!" : "Не хватает \(abs($0)) перышек" }
    
    let buy = input.alertBuyButtonClick.withLatestFrom(points) { _, points in
      var bird  = self.bird
      bird.isBought = true
      self.services.birdService.saveBird(bird: bird)
      for point in points {
        self.services.pointService.removePointFromCoreData(point: point)
      }
    }
    
    return Output(
      // title
      title: title,
      // image
      image: image,
      // description
      description: description,
      // dataSource
      dataSource: dataSource,
      // price
      price: price,
      // buyButtonIsHidden
      buyButtonIsHidden: buyButtonIsHidden,
      // isBoughtLabel
      isBoughtLabel: isBoughtLabel,
      // buyAlertViewIsHidden
      buyAlertViewIsHidden: buyAlertViewIsHidden,
      // eggImageView
      eggImageView: eggImageView,
      //birdImageView
      birdImageView: birdImageView,
      // buyButtonIsEnabled
      buyButtonIsEnabled: buyButtonIsEnabled,
      // labelText
      labelText: labelText,
      // back
      back: back,
      // selection
      selection: selection,
      // buy
      buy: buy
    )
  }
}
