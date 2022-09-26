//
//  KindOfTaskListItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 25.09.2022.
//

import RxDataSources

enum KindOfTaskListItemType {
 // case Assigned(style: Style)
  case Empty
  case Locked
  case WithRepeatButton
}

struct KindOfTaskListItem: IdentifiableType, Equatable {

  // IdentifiableType
  var identity: String { kindOfTask.UID }
  
  // Props
  let kindOfTask: KindOfTask
  let type: KindOfTaskListItemType
  
  // Equatable
  static func == (lhs: KindOfTaskListItem, rhs: KindOfTaskListItem) -> Bool {
    lhs.identity == rhs.identity
  }
}

