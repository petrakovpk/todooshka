//
//  UserProfileItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import RxDataSources

struct UserProfileItem: IdentifiableType, Equatable {

  var identity: String { type.rawValue }
  var type: UserProfileCellType
  var leftText: String
  var rightText: String

  static func == (lhs: UserProfileItem, rhs: UserProfileItem) -> Bool {
    lhs.leftText == rhs.rightText
  }
}
