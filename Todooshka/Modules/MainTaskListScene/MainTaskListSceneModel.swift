//
//  MainTaskListSceneModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 08.04.2022.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class MainTaskListSceneModel: Stepper {
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices

  struct Input {
   
  }
  
  struct Output {
    // background
    let background: Driver<UIImage?>
    // actions
    let runActions: Driver<[SceneAction]>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    // actions
    let actions = services.actionService.actions
      .asDriver()
      .map {
        $0.filter {
          switch $0.action {
          case .CreateTheEgg(_), .RemoveTheEgg, .HatchTheBird(_):
            return true
          default:
            return false
          }
        }
      }
    
    // timer
    let timer = Driver<Int>
      .interval(RxTimeInterval.seconds(5))
    
    // background
    let background = timer
      .map{ _ in self.getBackgroundImage(date: Date()) }
      .startWith(self.getBackgroundImage(date: Date()))
      .distinctUntilChanged()

    // run actions
    let runActionsTrigger = services.actionService.runMainTaskListActionsTrigger.asDriver()
    
    let runActions = runActionsTrigger
      .withLatestFrom(actions) { $1 }

    return Output(
      background: background,
      runActions: runActions
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
