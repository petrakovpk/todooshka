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
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices

  struct Input {
   
  }
  
  struct Output {
    // background
    let backgroundImage: Driver<UIImage?>
    // actions
    let run: Driver<[NestSceneAction]>
    // birds
    let birds: Driver<[Bird]>
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
    let backgroundImage = timer
      .map{ _ in self.getBackgroundImage(date: Date()) }
      .startWith(self.getBackgroundImage(date: Date()))
      .distinctUntilChanged()
    
    // nestSceneActions
    let nestSceneActions = services.actionService.nestSceneActions
      .asDriver()
    
    // trigger
    let trigger = services.actionService
      .runNestSceneActionsTrigger
      .asDriver()
    
    let run = trigger
      .withLatestFrom(nestSceneActions) { $1 }
    
    let birds = services.birdService.birds.asDriver()

    return Output(
      backgroundImage: backgroundImage,
      run: run,
      birds: birds
    )
  }
  
  // Helpers
  func getBackgroundImage(date: Date) -> UIImage? {
    let hour = Date().hour
    switch hour {
    case 0...5: return UIImage(named: "ночь01")
    case 6...11: return UIImage(named: "утро01")
    case 12...17: return UIImage(named: "день01")
    case 18...23: return UIImage(named: "вечер01")
    default: return nil
    }
  }
}
