//
//  FollowersItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import RxDataSources

struct FollowersItem {
  let userUID: String
  let image: UIImage
  let nick: String
  let name: String
}

extension FollowersItem: IdentifiableType {
  var identity: String {
    userUID + nick + name
  }
}

extension FollowersItem: Equatable {
  static func == (lhs: FollowersItem, rhs: FollowersItem) -> Bool {
    lhs.userUID == rhs.userUID &&
    lhs.nick == rhs.nick &&
    lhs.name == rhs.name
  }
}


