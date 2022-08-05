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
  var nestSceneActions = BehaviorRelay<[NestSceneAction]>(value: [])
  var branchSceneActions = BehaviorRelay<[BranchSceneAction]>(value: [])
  var runNestSceneActionsTrigger = BehaviorRelay<Void>(value: ())
  var runUserProfileActionsTrigger = BehaviorRelay<Void>(value: ())
  var tabBarSelectedItem = BehaviorRelay<TabBarItemSelected>(value: .TaskList)
  
  // MARK: - Init
  init() {
    
  }
 
  // MARK: - Adding
  func addNestSceneActions(actions: [NestSceneAction]) {
    self.nestSceneActions.accept(self.nestSceneActions.value + actions)
  }
  
  func addBranchSceneActions(actions: [BranchSceneAction]) {
    self.branchSceneActions.accept(self.branchSceneActions.value + actions)
  }
  
  // MARK: - Removing
  func removeAllNestSceneActions() {
    
  }
  
  func removeAllBranchSceneActions() {
    
  }
  
  func removeNestSceneActions(nestSceneActions: [NestSceneAction]) {
    nestSceneActions.forEach { nestSceneAction in
      if let index = self.nestSceneActions.value.firstIndex(where: { $0.UID == nestSceneAction.UID }) {
        var nestSceneActions = self.nestSceneActions.value
        nestSceneActions.remove(at: index)
        self.nestSceneActions.accept(nestSceneActions)
      }
    }
  }
  
  func removeBranchSceneActions(branchSceneActions: [BranchSceneAction]) {
    branchSceneActions.forEach { branchSceneAction in
      if let index = self.branchSceneActions.value.firstIndex(where: { $0.UID == branchSceneAction.UID }) {
        var branchSceneActions = self.branchSceneActions.value
        branchSceneActions.remove(at: index)
        self.branchSceneActions.accept(branchSceneActions)
      }
    }
  }
  
}
