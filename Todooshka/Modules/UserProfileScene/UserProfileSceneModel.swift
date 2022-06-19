//
//  UserProfileSceneModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 07.06.2022.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class UserProfileSceneModel: Stepper {
  
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
          case .RunTheBird(_), .RemoveLastBird:
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
    let runActionsTrigger = services.actionService.runUserProfileActionsTrigger.asDriver()
    
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
    case 0...5: return UIImage(named: "ночь02")
    case 6...11: return UIImage(named: "утро02")
    case 12...17: return UIImage(named: "день02")
    case 18...23: return UIImage(named: "вечер02")
    default: return nil
    }
  }
}

