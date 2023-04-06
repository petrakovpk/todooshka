//
//  BranchSceneModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 07.06.2022.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class MainCalendarSceneModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let willShow = BehaviorRelay<Void?>(value: nil)

  struct Input {
  }

  struct Output {
//    let backgroundImage: Driver<UIImage?>
//    let birds: Driver<[Bird]>
//    let dataSource: Driver<[BirdActionType]>
//    let forceNestUpdate: Driver<Void>
//    let forceBranchUpdate: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
//    let birds = services.dataService.birds
//    let dataSource = services.dataService.branchDataSource
//
//    let forceNestUpdate = willShow
//      .compactMap { $0 }
//      .asDriver(onErrorJustReturn: ())
//      .map { self.services.actionService.forceNestSceneTrigger.accept(()) }
//
//    let forceBranchUpdate = services.actionService.forceBranchSceneTrigger
//      .compactMap { $0 }
//      .asDriver(onErrorJustReturn: ())
//
//    let timer = Driver<Int>
//      .interval(RxTimeInterval.seconds(5))
//
//    let backgroundImage = timer
//      .map { _ in self.getBackgroundImage(date: Date()) }
//      .startWith(self.getBackgroundImage(date: Date()))
//      .distinctUntilChanged()

    return Output(
//      backgroundImage: backgroundImage,
//      birds: birds,
//      dataSource: dataSource,
//      forceNestUpdate: forceNestUpdate,
//      forceBranchUpdate: forceBranchUpdate
    )
  }

  // Helpers
  func getBackgroundImage(date: Date) -> UIImage? {
    let hour = Date().hour
    switch hour {
    case 0...5: return UIImage(named: "ночь02")
    case 6...11: return UIImage(named: "утро02")
    case 12...17: return UIImage(named: "день02")
    case 18...23: return UIImage(named: "вечер02")
    default: return nil
    }
  }
}
