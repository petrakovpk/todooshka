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
    // egg
    let actions: Driver<[EggAction]>
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

    // egg
    let eggs = services.birdService.eggs
    let initialEggs = services.birdService.eggs.value
        
    let actions = eggs
      .withPrevious(startWith: [])
      .map { (previous, current) -> [EggAction] in
        var result: [EggAction] = []
        
        for pr in previous {
          // если яйцо пропало
          if current.first(where: { $0.UID == pr.UID }) == nil {
            result.append(.Remove(egg: pr))
          }
        }
        
        for cur in current {
          // если яйцо появилось
          if previous.first(where: { $0.UID == cur.UID }) == nil {
            result.append(.Create(egg: cur, withAnimation: true))
          }
        }
   
        return result
      }
      .asDriver(onErrorJustReturn: [])
      .startWith(initialEggs.map{ .Create(egg: $0, withAnimation: false) } )
  
    return Output(
      background: background,
      actions: actions
    )
  }
  
  // Helpers
  func viewWillAppear() {
    services.tasksService.reloadDataSource.accept(())
  }
  
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
