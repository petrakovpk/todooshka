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
    let saveAction: Driver<[MainTaskListSceneAction]>
    let runActions: Driver<[MainTaskListSceneAction]>
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
    
    // eggs
    let eggs = services.actionService.eggs.asDriver()
    
    // actions
    let createTheEggAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { previous, current -> [Task] in
        current
          .filter { task -> Bool in
            task.status == .InProgress && previous.first(where: { $0.UID == task.UID })?.status != task.status
          }
      }
      .map {
        $0.compactMap { task -> MainTaskListSceneAction? in
          if let clade = task.type(withTypeService: self.services)?.bird(withBirdService: self.services)?.clade {
            return MainTaskListSceneAction(
              UID: UUID().uuidString,
              action: .CreateTheEgg(
                egg: Egg(
                  UID: task.UID,
                  clade: clade,
                  created: task.created),
                withAnimation: true),
              status: .ReadyToRun
            )
          } else { return nil }
        }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
    
    let changeEggCladeAction = services.tasksService.tasks
      .withLatestFrom(eggs) { tasks, eggs -> [MainTaskListSceneAction] in
        tasks.compactMap { task -> MainTaskListSceneAction? in
          if var egg = eggs.first(where: {$0.UID == task.UID}),
             let clade = task.type(withTypeService: self.services)?.bird(withBirdService: self.services)?.clade {
            self.services.actionService.removeAllActionsForEgg(egg: egg)
            if egg.clade != clade {
              egg.clade = clade
              return  MainTaskListSceneAction(
                UID: UUID().uuidString,
                action: .ChangeEggClyde(egg: egg),
                status: .ReadyToRun
              )
            }
          }
          return nil
        }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
    
    let breakTheEggAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { previous, current -> [Task] in
        previous
          .filter { task -> Bool in
            current.contains(where: { $0.UID == task.UID && task.status == .InProgress && $0.status != .InProgress && $0.status != .Completed })
          }
      }
      .withLatestFrom(eggs) { tasks, eggs -> [MainTaskListSceneAction] in
        tasks.compactMap { task -> MainTaskListSceneAction? in
          if let egg = eggs.first(where: { $0.UID == task.UID }) {
            return MainTaskListSceneAction(
              UID: UUID().uuidString,
              action: .BrokeTheEggWithoutBird(egg: egg),
              status: .ReadyToRun
            )
          } else { return nil }
        }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
    
    let brokeTheEggAndBornTheBirdAndSendTheBirdWalkToTheRight = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { previous, current -> [Task] in
        previous
          .filter { task -> Bool in
            current.contains(where: { $0.UID == task.UID && task.status == .InProgress && $0.status == .Completed })
          }
      }
      .withLatestFrom(eggs) { tasks, eggs -> [MainTaskListSceneAction] in
        tasks.compactMap { task -> MainTaskListSceneAction? in
          if let egg = eggs.first(where: { $0.UID == task.UID }) {
            return MainTaskListSceneAction(
              UID: UUID().uuidString,
              action: .BrokeTheEggAndBornTheBirdAndSendTheBirdWalkToTheRight(egg: egg),
              status: .ReadyToRun
            )
          } else { return nil }
        }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
    
    let saveAction = Driver.of(
      createTheEggAction,
      changeEggCladeAction,
      breakTheEggAction,
      brokeTheEggAndBornTheBirdAndSendTheBirdWalkToTheRight
    )
      .merge()
      .do {
        self.services.actionService.addAction(actions: $0)
      }
    
    let runActionsTrigger = services.actionService.runActionsTrigger.asDriver()
    let readyForRunActions = services.actionService.actions.asDriver()
    
    // runActions
    let runActions = runActionsTrigger
      .withLatestFrom(readyForRunActions) { $1 }
      .do { actions in
        actions.forEach { action in
          switch action.action {
          case .CreateTheEgg(let egg, _):
            self.services.actionService.saveEgg(egg: egg)
          case .ChangeEggClyde(let egg):
            self.services.actionService.saveEgg(egg: egg)
          case .BrokeTheEggWithoutBird(let egg):
            self.services.actionService.removeEgg(egg: egg)
          case .BrokeTheEggAndBornTheBirdAndSendTheBirdWalkToTheRight(let egg):
            self.services.actionService.removeEgg(egg: egg)
          default:
            return
          }
        }
      }

    return Output(
      background: background,
      saveAction: saveAction,
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
