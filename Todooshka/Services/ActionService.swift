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
  var actions = BehaviorRelay<[SceneAction]>(value: [])
  var runMainTaskListActionsTrigger = BehaviorRelay<Void>(value: ())
  var runUserProfileActionsTrigger = BehaviorRelay<Void>(value: ())
  var tabBarSelectedItem = BehaviorRelay<TabBarItemSelected>(value: .TaskList)
  
  // MARK: - Init
  init() {
    
  }
 
  // MARK: - Actions
  func addActions(actions: [SceneAction]) {
    self.actions.accept(self.actions.value + actions)
  }
  
  func removeActions(actions: [SceneAction]) {
    actions.forEach { action in
      if let index = self.actions.value.firstIndex(where: { $0.UID == action.UID }) {
        var actions = self.actions.value
        actions.remove(at: index)
        self.actions.accept(actions)
      }
    }
  }
  
}
