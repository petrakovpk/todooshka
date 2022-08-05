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

class BranchSceneModel: Stepper {
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices

  struct Input {
   
  }
  
  struct Output {
    // background
    let background: Driver<UIImage?>
    // actions
    let run: Driver<[BranchSceneAction]>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    // timer
    let timer = Driver<Int>
      .interval(RxTimeInterval.seconds(5))
    
    // background
    let background = timer
      .map{ _ in self.getBackgroundImage(date: Date()) }
      .startWith(self.getBackgroundImage(date: Date()))
      .distinctUntilChanged()
    
    // branchSceneActions
    let branchSceneActions = services.actionService.branchSceneActions
      .asDriver()
    
    // run actions
    let trigger = services.actionService.runUserProfileActionsTrigger.asDriver()
    
    let run = trigger
      .withLatestFrom(branchSceneActions) { $1 }
    
    let birds = services.birdService.birds.asDriver()

    return Output(
      background: background,
      run: run
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

