//
//  KindOfTaskForBirdItem.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.05.2022.
//

import RxDataSources

enum KindOfTaskForBirdItemType: Equatable {
  case kindOfTask(kindOfTask: KindOfTask, isEnabled: Bool)
  case isPlusButton
}

struct KindOfTaskForBirdItem: IdentifiableType, Equatable {
  let kindOfTaskType: KindOfTaskForBirdItemType

  // MARK: - Identity
  var identity: String {
    switch kindOfTaskType {
    case .isPlusButton:
      return "plus"
    case .kindOfTask(let kindOfTask, let isEnabled):
      return kindOfTask.UID + isEnabled.string
    }
  }

  // MARK: - Equatable
  static func == (lhs: KindOfTaskForBirdItem, rhs: KindOfTaskForBirdItem) -> Bool {
    lhs.identity == rhs.identity
  }
}
