//
//  ActionService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 08.05.2022.
//

import CoreData
import RxSwift
import RxCocoa

protocol HasActionService {
  var actionService: ActionService { get }
}

class ActionService {
  // MARK: - Properties
  var runBranchSceneActionsTrigger = BehaviorRelay<Void>(value: ())
  var forceNestSceneTrigger = BehaviorRelay<Void?>(value: nil)
  var forceBranchSceneTrigger = BehaviorRelay<Void?>(value: nil)

  // MARK: - Init
  init() {
  }
}
