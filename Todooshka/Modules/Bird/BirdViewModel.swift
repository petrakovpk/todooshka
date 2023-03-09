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
    let currency: Driver<Currency>
    let eggImageView: Driver<UIImage?>
    let dataSource: Driver<[KindOfTaskForBirdSection]>
    let description: Driver<String>
    let kindOfTaskImageView: Driver<UIImage?>
    let navigateBack: Driver<Void>
    let plusButtonClickTrigger: Driver<Void>
    let price: Driver<String>
    let title: Driver<String>
  }

  // MARK: - Init
  init(birdUID: String, services: AppServices) {
    self.birdUID = birdUID
    self.services = services
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let birds = services.dataService
      .birds

    let bird = birds
      .compactMap { $0.first { $0.UID == self.birdUID } }

    let kindsOfTask = services.dataService.kindsOfTask.asDriver()

    let kindOfTaskImageView = kindsOfTask
      .withLatestFrom(bird) { kindsOfTask, bird -> KindOfTask? in
        kindsOfTask.first { $0.UID == bird.style.rawValue }
      }
      .map { $0?.icon.image }
      .asDriver(onErrorJustReturn: nil)

    let buyButtonIsHidden = bird
      .map { $0.isBought }

    let buyLabelIsHidden = buyButtonIsHidden
      .map { !$0 }

    let description = bird
      .map { $0.style.description }

    let eggImageView = bird
      .map { $0.eggImage }

    let birdImageView = bird
      .map { $0.getImageForState(state: .normal) }

    let price = bird
      .map { $0.price }
      .map { $0.string }

    let currency = bird
      .map { $0.currency }

    let title = bird
      .map { $0.name }

    let kindOfTaskMain = Driver
      .combineLatest(kindsOfTask, bird) { kindsOfTask, bird -> [KindOfTask] in
        kindsOfTask.filter { $0.style.rawValue == bird.style.rawValue }
      }

    let kindsOfTaskNotOpenedBird = birds
    // получаем неоткрытые стили на текущем уровне
      .withLatestFrom(bird) { birds, bird -> [BirdStyle] in
        birds
          .filter { $0.clade == bird.clade }
          .filter { $0.isBought == false }
          .map { $0.style }
      }
    // присваиваем для них кайндофтайпы
      .withLatestFrom(kindsOfTask) { styles, kindsOfTask -> [KindOfTask] in
        kindsOfTask
          .filter { kindOfTask -> Bool in
            styles.contains { $0.rawValue == kindOfTask.style.rawValue }
          }
      }

    let kindsOfTaskForDataSource = Driver
      .combineLatest(bird, kindOfTaskMain, kindsOfTaskNotOpenedBird) { bird, kindOfTaskMain, kindsOfTaskNotOpenedBird -> [KindOfTask] in
        bird.style == .simple ? kindOfTaskMain + kindsOfTaskNotOpenedBird : kindOfTaskMain
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
      .map { self.steps.accept(AppStep.navigateBack) }

    // selectedKindOfTask
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> KindOfTaskForBirdItem in
        dataSource[indexPath.section].items[indexPath.item]
      }

    let plusButtonClickTrigger = selection
      .filter { $0.kindOfTaskType == .isPlusButton }
      .withLatestFrom(bird) { $1 }
      .filter { $0.isBought }
      .map { _ in self.steps.accept(AppStep.kindOfTaskWithBird(birdUID: self.birdUID)) }

    let diamondsCount = services.dataService.diamonds.map { $0.count }
    let feathersCount = services.dataService.feathersCount

    let alertBuyButtonIsEnabled = Driver
      .combineLatest(bird, feathersCount, diamondsCount) { bird, feathersCount, diamondsCount -> Bool in
        bird.currency == .feather ? feathersCount >= bird.price : diamondsCount >= bird.price
      }

    let alertLabelText = Driver
      .combineLatest(bird, feathersCount, diamondsCount) { bird, feathersCount, diamondsCount -> String in
        switch bird.currency {
        case .feather:
          return feathersCount >= bird.price ? "Можете купить!" : "Не хватает \( abs(feathersCount - bird.price) ) перышек"
        case .diamond:
          return diamondsCount >= bird.price ? "Можете купить!" : "Не хватает \( abs(diamondsCount - bird.price) ) бриллиантиков"
        }
      }

    let buy = input.alertBuyButtonClick
      .withLatestFrom(bird) { _, bird -> Bird in
        var bird = bird
        bird.isBought = true
        return bird
      }
      .asObservable()
      .flatMapLatest { bird -> Observable<Result<Void, Error>> in
        self.managedContext.rx.update(bird)
      }
      .asDriverOnErrorJustComplete()

    let buySuccess = buy
      .compactMap { result -> Void? in
        guard case .success = result else { return nil }
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
      currency: currency,
      eggImageView: eggImageView,
      dataSource: dataSource,
      description: description,
      kindOfTaskImageView: kindOfTaskImageView,
      navigateBack: navigateBack,
      plusButtonClickTrigger: plusButtonClickTrigger,
      price: price,
      title: title
    )
  }
}
