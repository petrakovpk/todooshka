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
  var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }
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
    let alertBuyButtonIsEnabled: Driver<Bool>
    let alertLabelText: Driver<String>
    let alertViewHide: Driver<Void>
    let alertViewShow: Driver<Void>
    let birdImageView: Driver<UIImage?>
    let buyButtonIsHidden: Driver<Bool>
    let buyLabelIsHidden: Driver<Bool>
    let eggImageView: Driver<UIImage?>
    let dataSource: Driver<[KindOfTaskForBirdSection]>
    let description: Driver<String>
    let kindOfTaskImageView: Driver<UIImage?>
    let navigateBack: Driver<Void>
    let plusButtonClickTrigger:  Driver<Void>
    let price: Driver<String>
    let title: Driver<String>
  }
  
  //MARK: - Init
  init(birdUID: String, services: AppServices) {
    self.birdUID = birdUID
    self.services = services
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    let birds = services.dataService
      .birds
    
    let bird = birds
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
      .map{ $0.style.text }
    
    let kindOfTaskMain = Driver
      .combineLatest(kindsOfTask, bird) { kindsOfTask, bird -> [KindOfTask] in
        kindsOfTask.filter{ $0.style.rawValue == bird.style.rawValue }
      }
    
    let kindsOfTaskNotOpenedBird = birds
    // получаем неоткрытые стили на текущем уровне
      .withLatestFrom(bird) { birds, bird -> [Style] in
        birds
          .filter { $0.clade == bird.clade }
          .filter { $0.isBought == false }
          .map { $0.style }
      }
    // присваиваем для них кайндофтайпы
      .withLatestFrom(kindsOfTask) { styles, kindsOfTask -> [KindOfTask] in
        kindsOfTask
          .filter { kindOfTask -> Bool in
            styles.contains(where: { $0.rawValue == kindOfTask.style.rawValue })
          }
      }

    let kindsOfTaskForDataSource = Driver
      .combineLatest(bird, kindOfTaskMain, kindsOfTaskNotOpenedBird) { bird, kindOfTaskMain, kindsOfTaskNotOpenedBird -> [KindOfTask] in
        bird.style == .Simple ? kindOfTaskMain + kindsOfTaskNotOpenedBird : kindOfTaskMain
      }

    // dataSource
    let dataSource = Driver.combineLatest(bird, kindsOfTaskForDataSource) { bird, kindsOfTask -> [KindOfTaskForBirdSection] in
      [
        KindOfTaskForBirdSection(
          header: "",
          items: kindsOfTask
            .map {
              KindOfTaskForBirdItem(kindOfTaskType: .kindOfTask(kindOfTask: $0, isEnabled: bird.isBought))
            } + [KindOfTaskForBirdItem(kindOfTaskType: .isPlusButton) ]
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
    
    let plusButtonClickTrigger = selection
      .filter { $0.kindOfTaskType == .isPlusButton }
      .withLatestFrom(bird) { $1 }
      .filter { $0.isBought }
      .map{ _ in self.steps.accept(AppStep.KindOfTaskWithBird(birdUID: self.birdUID)) }
    
    let feathersCount = services.dataService.feathersCount
    
    let diamonds = services.dataService.diamonds
      .asDriver(onErrorJustReturn: [])

   let alertBuyButtonIsEnabled = bird
      .withLatestFrom(feathersCount) { $1 >= $0.price ? true : false }
    
    let alertLabelText = bird
      .withLatestFrom(feathersCount) { $1 >= $0.price ? "Можете купить!" : "Не хватает \( $1 - $0.price ) перышек" }
    
    let buy = input.alertBuyButtonClick
      .withLatestFrom(bird){ _, bird -> Bird in
        var bird = bird
        bird.isBought = true
        return bird
      }.asObservable()
      .flatMapLatest { bird -> Observable<Result<Void, Error>> in
        self.managedContext.rx.update(bird)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let buySuccess = buy
      .compactMap { result -> Void? in
        guard case .success(_) = result else { return nil }
        return ()
      }
    
    let alertViewHide = Driver
      .of(input.alertCancelButtonClick, buySuccess)
      .merge()
    
    let alertViewShow = input.buyButtonClickTrigger
    
    return Output(
      alertBuyButtonIsEnabled: alertBuyButtonIsEnabled,
      alertLabelText: alertLabelText,
      alertViewHide: alertViewHide,
      alertViewShow: alertViewShow,
      birdImageView: birdImageView,
      buyButtonIsHidden: buyButtonIsHidden,
      buyLabelIsHidden: buyLabelIsHidden,
      eggImageView: eggImageView,
      dataSource: dataSource,
      description: description,
      kindOfTaskImageView: kindOfTaskImageView,
      navigateBack: navigateBack,
      plusButtonClickTrigger: plusButtonClickTrigger,
      price: price,
      //selectedKindOfTask: selectedKindOfTask,
      title: title
    )
  }
}
