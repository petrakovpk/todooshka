//
//  EmptyFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 19.11.2022.
//

import RxFlow

class EmptyFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }
  
  private let rootViewController = UINavigationController()
  
  func navigate(to step: Step) -> FlowContributors {
    return .none
  }
}
