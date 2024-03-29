//
//  NestSceneModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 08.04.2022.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class NestSceneModel: Stepper {

  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices

  let willShow = BehaviorRelay<Void?>(value: nil)

  struct Input {

  }

  struct Output {
    // background
    let backgroundImage: Driver<UIImage?>
    // birds
    let birds: Driver<[Bird]>
    // dataSource
    let dataSource: Driver<[EggActionType]>
    // force
    let forceNestUpdate: Driver<Void>
    let forceBranchUpdate: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {

    // timer
    let timer = Driver<Int>
      .interval(RxTimeInterval.seconds(5))

    // background
    let backgroundImage = timer
      .map { _ in self.getBackgroundImage(date: Date()) }
      .startWith(self.getBackgroundImage(date: Date()))
      .distinctUntilChanged()

    let birds = services.dataService.birds

    let dataSource = services.dataService.nestDataSource

    let forceNestUpdate = services.actionService.forceNestSceneTrigger
      .compactMap { $0 }
      .asDriver(onErrorJustReturn: ())

    let forceBranchUpdate = willShow
      .compactMap { $0 }
      .asDriver(onErrorJustReturn: ())
      .do { _ in
        self.services.actionService.forceBranchSceneTrigger.accept(())
      }

    return Output(
      backgroundImage: backgroundImage,
     // backgroundBottomImage: backgroundBottomImage,
      birds: birds,
      dataSource: dataSource,
      forceNestUpdate: forceNestUpdate,
      forceBranchUpdate: forceBranchUpdate
    )
  }

  // Helpers
  func getBackgroundImage(date: Date) -> UIImage? {
    switch Date().hour {
    case 0...5: return UIImage(named: "ночь01")
    case 6...11: return UIImage(named: "утро01")
    case 12...17: return UIImage(named: "день01")
    case 18...23: return UIImage(named: "вечер01")
    default: return nil
    }
  }
}
