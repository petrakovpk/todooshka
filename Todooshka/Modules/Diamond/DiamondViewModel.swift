//
//  DiamondViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 20.06.2022.
//

import RxFlow
import RxSwift
import RxCocoa

class DiamondViewModel: Stepper {

  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  // MARK: - Transform
  struct Input {
    // button
    let backButtonClickTrigger: Driver<Void>
    // offer
    let smallOfferBackgroundClickTrigger: Driver<Void>
    let mediumOfferBackgroundClickTrigger: Driver<Void>
    let largeOfferBackgroundClickTrigger: Driver<Void>
    // buy
    let buyButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // button
    let backButtonClickHandler: Driver<Void>
    // offer
    let offerSelected: Driver<DiamondPackageType>
    // buy button
    let buyButtonClick: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    // backButtonClickHandler
    let backButtonClickHandler = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.NavigateBack) }
    
    // offerSelected
    let smallOfferSelected = input.smallOfferBackgroundClickTrigger.map{ DiamondPackageType.Small }.asDriver()
    let mediumOfferSelected = input.mediumOfferBackgroundClickTrigger.map{ DiamondPackageType.Medium }.asDriver()
    let largeOfferSelected = input.largeOfferBackgroundClickTrigger.map{ DiamondPackageType.Large }.asDriver()
    
    let offerSelected = Driver
      .of(smallOfferSelected, mediumOfferSelected, largeOfferSelected)
      .merge()
      .startWith(.Medium)
    
    // buyButtonClick
    let buyButtonClick = input.buyButtonClickTrigger
    
    return Output(
      backButtonClickHandler: backButtonClickHandler,
      offerSelected: offerSelected,
      buyButtonClick: buyButtonClick
    )
  }

}


