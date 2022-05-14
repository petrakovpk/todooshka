//
//  ActionService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 08.05.2022.
//

import CoreData
import RxSwift
import RxCocoa

enum TabBarItemSelected {
  case TaskList
  case UserProfile
}


protocol HasActionService {
  var actionService: ActionService { get }
}

class ActionService {
  
  // MARK: - Properties
  var eggs = BehaviorRelay<[Egg]>(value: [])
  var actions = BehaviorRelay<[MainTaskListSceneAction]>(value: [])
  var runActionsTrigger = BehaviorRelay<Void>(value: ())
  var tabBarSelectedItem = BehaviorRelay<TabBarItemSelected>(value: .TaskList)
  
  // MARK: - Init
  init() {
    
  }
  
  // MARK: - Eggs
  func saveEgg(egg: Egg) {
    
    if let index = eggs.value.firstIndex(where: { $0.UID == egg.UID }) {
      var eggs = self.eggs.value
      eggs[index] = egg
      self.eggs.accept(eggs)
    } else {
      self.eggs.accept(self.eggs.value + [egg])
    }
  }
  
  func removeEgg(egg: Egg) {
    if let index = self.eggs.value.firstIndex(where: { $0.UID == egg.UID }) {
      var eggs = self.eggs.value
      eggs.remove(at: index)
      self.eggs.accept(eggs)
    }
  }
  
  // MARK: - Actions
  func addAction(actions: [MainTaskListSceneAction]) {
    self.actions.accept(self.actions.value + actions)
  }
  
  func removeAllActionsForEgg(egg: Egg) {
    removeActions(
      actions: actions.value
      .filter { action -> Bool in
        switch action.action {
        case .CreateTheEgg(let newEgg, _),
            .ChangeEggClyde(let newEgg),
            .BrokeTheEggWithoutBird(let newEgg):
          return egg.UID == newEgg.UID
        default:
          return false
        }
      }
    )
  }
  
  func removeActions(actions: [MainTaskListSceneAction]) {
    actions.forEach { action in
      if let index = self.actions.value.firstIndex(where: { $0.UID == action.UID }) {
        var actions = self.actions.value
        actions.remove(at: index)
        self.actions.accept(actions)
      }
    }
  }
  
}
