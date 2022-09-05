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
  var nestDataSource = BehaviorRelay<[Int: EggActionType]>(value: [:])
  var branchDataSource = BehaviorRelay<[Int: BirdActionType]>(value: [:])
 // var runNestSceneActionsTrigger = BehaviorRelay<Void>(value: ())
  var runBranchSceneActionsTrigger = BehaviorRelay<Void>(value: ())
  var forceNestSceneTrigger = BehaviorRelay<Void?>(value: nil)
  var forceBranchSceneTrigger = BehaviorRelay<Void?>(value: nil)
  
  // MARK: - Init
  init() {
    
  }
 
}
