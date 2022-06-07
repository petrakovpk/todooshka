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
    let createActions: Driver<[SceneAction]>
    let runActions: Driver<[SceneAction]>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    // actions
    let actions = services.actionService.actions.asDriver()
    
    // timer
    let timer = Driver<Int>
      .interval(RxTimeInterval.seconds(5))
    
    // background
    let background = timer
      .map{ _ in self.getBackgroundImage(date: Date()) }
      .startWith(self.getBackgroundImage(date: Date()))
      .distinctUntilChanged()
    
    // actions
    let createTheEggAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { previous, current -> [SceneAction] in
        current
          .filter { task -> Bool in
            task.status == .InProgress &&
            task.status != previous.first(where: { $0.UID == task.UID })?.status
          }
          .map { _ in
            SceneAction(UID: UUID().uuidString, action: .CreateTheEgg(withAnimation: true))
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])

    let removeTheEggAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { previous, current -> [SceneAction] in
        previous
          .filter { task -> Bool in
            current.contains(where: {
              task.status == .InProgress &&
              $0.UID == task.UID &&
              $0.status != .InProgress && $0.status != .Completed
            })
          }
          .map { _ in
            SceneAction(UID: UUID().uuidString, action: .RemoveTheEgg)
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
     
    let hatchTheBirdAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { previous, current -> [SceneAction] in
        previous
          .filter { task -> Bool in
            current.contains(where: {
              task.status == .InProgress &&
              $0.UID == task.UID &&
              $0.status == .Completed
            })
          }
          .map { task -> SceneAction in
            let birds = self.services.birdService.birds.value
              .filter({ $0.typesUID.contains(where: { $0 == task.typeUID }) })
            return SceneAction(UID: UUID().uuidString, action: .HatchTheBird(birds: birds))
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
    
    let createActions = Driver.of(
      createTheEggAction,
      hatchTheBirdAction,
      removeTheEggAction
    )
      .merge()
      .do {
        self.services.actionService.addActions(actions: $0)
      }
    
    // run actions
    let runActionsTrigger = services.actionService.runActionsTrigger.asDriver()
    
    let runActions = runActionsTrigger
      .withLatestFrom(actions) { $1 }

    return Output(
      background: background,
      createActions: createActions,
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
