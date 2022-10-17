//
//  DiamondViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 20.06.2022.
//

import RxFlow
import RxSwift
import RxCocoa
import YandexMobileMetrica

class DiamondViewModel: Stepper {

  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  // MARK: - Transform
  struct Input {
    let alertOkButtonClickTrigger: Driver<Void>
    let backButtonClickTrigger: Driver<Void>
    let buyButtonClickTrigger: Driver<Void>
    let smallOfferBackgroundClickTrigger: Driver<Void>
    let largeOfferBackgroundClickTrigger: Driver<Void>
    let mediumOfferBackgroundClickTrigger: Driver<Void>
  }
  
  struct Output {
    let hideAlertTrigger: Driver<Void>
    let navigateBack: Driver<Void>
    let offerSelected: Driver<DiamondPackageType>
    let sendOffer: Driver<Void>
    let showAlertTrigger: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    let compactUser = services.dataService.compactUser
    
    // backButtonClickHandler
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.NavigateBack) }
    
    // offerSelected
    let smallOfferSelected = input.smallOfferBackgroundClickTrigger.map{ DiamondPackageType.Small }.asDriver()
    let mediumOfferSelected = input.mediumOfferBackgroundClickTrigger.map{ DiamondPackageType.Medium }.asDriver()
    let largeOfferSelected = input.largeOfferBackgroundClickTrigger.map{ DiamondPackageType.Large }.asDriver()
    
    let offerSelected = Driver
      .of(smallOfferSelected, mediumOfferSelected, largeOfferSelected)
      .merge()
      .startWith(.Medium)
    
    let hideAlertTrigger = input.alertOkButtonClickTrigger
    
    let sendOffer = input.alertOkButtonClickTrigger
      .withLatestFrom(offerSelected) { $1 }
      .withLatestFrom(compactUser) { offer, user in
        let params: [AnyHashable : Any] = ["offer": offer.rawValue]
        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: nil)
        return DB_USERS_REF.child(user.uid).child("BUY").child(Date().startOfDay.description).updateChildValues([Date().description : offer.rawValue])
      }
    
    let showAlertTrigger = input.buyButtonClickTrigger
    
    return Output(
      hideAlertTrigger: hideAlertTrigger,
      navigateBack: navigateBack,
      offerSelected: offerSelected,
      sendOffer: sendOffer,
      showAlertTrigger: showAlertTrigger
    )
  }

}


