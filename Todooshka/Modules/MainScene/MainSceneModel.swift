//
//  MainSceneModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 26.01.2023.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class MainSceneModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let willShow = BehaviorRelay<Void?>(value: nil)

  struct Input {
  }

  struct Output {
    
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
  

    return Output(
      
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

