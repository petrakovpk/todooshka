//
//  FunItemType.swift
//  DragoDo
//
//  Created by Pavel Petakov on 13.04.2023.
//

import RxDataSources

enum FunCellType {
  case task(FunItem)
  case noMoreTasks
}

extension FunCellType: IdentifiableType {
  var identity: String {
    switch self {
    case .noMoreTasks:
      return "noMoreTasks"
    case .task(let funItemTask):
      return funItemTask.identity
    }
  }
}

extension FunCellType: Equatable {
    static func ==(lhs: FunCellType, rhs: FunCellType) -> Bool {
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
