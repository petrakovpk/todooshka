//
//  FunItemType.swift
//  DragoDo
//
//  Created by Pavel Petakov on 13.04.2023.
//

import RxDataSources

enum FunItemType {
  case task(FunItemTask)
  case noMoreTasks
}

extension FunItemType: IdentifiableType {
  var identity: String {
    switch self {
    case .noMoreTasks:
      return "noMoreTasks"
    case .task(let funItemTask):
      return funItemTask.identity
    }
  }
}

extension FunItemType: Equatable {
    static func ==(lhs: FunItemType, rhs: FunItemType) -> Bool {
        switch (lhs, rhs) {
        case (.task(let lhsTask), .task(let rhsTask)):
            return lhsTask == rhsTask
        case (.noMoreTasks, .noMoreTasks):
            return true
        default:
            return false
        }
    }
}
