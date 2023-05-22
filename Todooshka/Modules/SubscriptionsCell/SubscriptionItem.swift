//
//  SubscriptionItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import RxDataSources

struct SubscriptionItem {
  let userUID: String
  let image: UIImage
  let nick: String
  let name: String
}

extension SubscriptionItem: IdentifiableType {
  var identity: String {
    userUID + nick + name
  }
}

extension SubscriptionItem: Equatable {
  static func == (lhs: SubscriptionItem, rhs: SubscriptionItem) -> Bool {
    lhs.userUID == rhs.userUID &&
    lhs.nick == rhs.nick &&
    lhs.name == rhs.name
  }
}

