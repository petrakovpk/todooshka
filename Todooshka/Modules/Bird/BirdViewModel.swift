//
//  BirdViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import CoreData
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class BirdViewModel: Stepper {

  // MARK: - Properties
  // context
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var managedContext: NSManagedObjectContext {
    self.appDelegate.persistentContainer.viewContext
  }
  // rx
  let steps = PublishRelay<Step>()
  let services: AppServices
  // bird
  let birdUID: String
  
  // MARK: - Transform
  struct Input {
    let alertBuyButtonClick: Driver<Void>
    let alertCancelButtonClick: Driver<Void>
    let backButtonClickTrigger: Driver<Void>
    let buyButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let addKindOfTask: Driver<Void>
    let birdImageView: Driver<UIImage?>
    let buyAlertViewIsHidden: Driver<Bool>
    let buyButtonIsEnabled: Driver<Bool>
    let buyButtonIsHidden: Driver<Bool>
    let buyLabelIsHidden: Driver<Bool>
    let eggImageView: Driver<UIImage?>
    let dataSource: Driver<[KindOfTaskForBirdSection]>
    let description: Driver<String>
    let kindOfTaskImageView: Driver<UIImage?>
    let labelText: Driver<String>
    let navigateBack: Driver<Void>
    let price: Driver<String>
    //let selectedKindOfTask: Driver<KindOfTask>
    let title: Driver<String>
  }
  
  //MARK: - Init
  init(birdUID: String, services: AppServices) {
    self.birdUID = birdUID
    self.services = services
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    let bird = services.dataService
      .birds
      .compactMap{ $0.first(where: { $0.UID == self.birdUID }) }
    
    let kindsOfTask = services.dataService.kindsOfTask.asDriver()
    
    let kindOfTaskImageView = kindsOfTask
      .withLatestFrom(bird) { kindsOfTask, bird -> KindOfTask? in
        kindsOfTask.first(where: { $0.UID == bird.style.rawValue })
      }.map{ $0?.icon.image }
      .asDriver(onErrorJustReturn: nil)
     

    let buyButtonIsHidden = bird
      .map{ $0.isBought }
    
    let buyLabelIsHidden = buyButtonIsHidden
      .map{ !$0 }
    
    let description = bird
      .map{ $0.description }
    
    let eggImageView = bird
      .map{ $0.eggImage }
    
    let birdImageView = bird
      .map{ $0.getImageForState(state: .Normal) }
    
    let price = bird
      .map{ $0.price }
      .map{ $0.string }
    
    let title = bird
      .map{ $0.name }
    
    // dataSource
    let dataSource = Driver.combineLatest(bird, kindsOfTask) { bird, kindsOfTask -> [KindOfTaskForBirdSection] in
      [
        KindOfTaskForBirdSection(
          header: "",
          items: kindsOfTask
            .filter { $0.UID == bird.style.rawValue }
            .map {
              KindOfTaskForBirdItem(
                kindOfTask: $0,
                isPlusButton: false,
                isRemovable: $0.UID != bird.style.rawValue
              )
            }
          + [KindOfTaskForBirdItem (kindOfTask: KindOfTask.Standart.Empty, isPlusButton: true, isRemovable: false)]
        )
      ]
    }
      .asDriver(onErrorJustReturn: [])

    // navigate back
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.NavigateBack) }
    
    // selectedKindOfTask
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> KindOfTaskForBirdItem in
        dataSource[indexPath.section].items[indexPath.item]
      }
    
    let addKindOfTask = selection
      .filter{ $0.isPlusButton }
      .map{ _ in self.steps.accept(AppStep.KindOfTaskWithBird(birdUID: self.birdUID)) }

//    let addKindOfTask = selectedKindOfTask
//      .withLatestFrom(bird) { kindOfTask, bird -> Bird in
//        var bird = bird
//        bird.kindsOfTaskUID.appendIfNotContains(kindOfTask.UID)
//        return bird
//      }.filter{ $0.isBought }
//      .asObservable()
//      .flatMapLatest({ self.managedContext.rx.update($0) })
      
    
//    let removeKindOfTask = selectedKindOfTask
//      .withLatestFrom(bird) { kindOfTask, birds -> [Bird] in
//        birds
//      }.map { $0.filter { $0.UID != self.birdUID } }
//    
//    
    
    
    
    
//    let
//      .withLatestFrom(bird) { type, bird -> KindOfTask in
//        guard bird.isBought else { return type }
///       self.services.birdService.linkBirdToTypeUID(bird: bird, type: type)
//        return type
//      }
//
    // buyAlertViewIsHidden
    let buyAlertViewIsHidden = Driver
      .of(
        input.buyButtonClickTrigger.map { false }, 
        input.alertCancelButtonClick.map { true },
        input.alertBuyButtonClick.map { true }
      )
      .merge()
    
    let feathers = services.dataService.feathers
      .asDriver(onErrorJustReturn: [])
    
    let diamonds = services.dataService.diamonds
      .asDriver(onErrorJustReturn: [])
    
    let possibilities = bird.withLatestFrom(feathers) { $1.count - $0.price }
    
    let buyButtonIsEnabled = possibilities.map{ $0 >= 0 ? true : false }
    
    let labelText = possibilities.map{ $0 >= 0 ? "Можете купить!" : "Не хватает \(abs($0)) перышек" }
    
//    let buy = input.alertBuyButtonClick.withLatestFrom(feathers) { _, gameCurrency in
//      var bird  = self.bird
//      bird.isBought = true
//     // self.services.birdService.saveBirdToCoreData(bird: bird)
//      for gameCurrencyForRemoving in gameCurrency {
//       // self.services.gameCurrencyService.removeGameCurrencyFromCoreData(gameCurrency: gameCurrencyForRemoving)
//      }
//    }
    
    return Output(
      addKindOfTask: addKindOfTask,
      birdImageView: birdImageView,
      buyAlertViewIsHidden: buyAlertViewIsHidden,
      buyButtonIsEnabled: buyButtonIsEnabled,
      buyButtonIsHidden: buyButtonIsHidden,
      buyLabelIsHidden: buyLabelIsHidden,
      eggImageView: eggImageView,
      dataSource: dataSource,
      description: description,
      kindOfTaskImageView: kindOfTaskImageView,
      labelText: labelText,
      navigateBack: navigateBack,
      price: price,
      //selectedKindOfTask: selectedKindOfTask,
      title: title
    )
  }
}
