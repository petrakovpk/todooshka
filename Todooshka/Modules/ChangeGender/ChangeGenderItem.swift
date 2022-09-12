//
//  ChangeGenderItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import RxDataSources

struct ChangeGenderItem: IdentifiableType, Equatable  {
  
  var identity: String { return UUID().uuidString }
  var text: String
  var isSelected: Bool
  var gender: Gender
  
  static func == (lhs: ChangeGenderItem, rhs: ChangeGenderItem) -> Bool {
    return lhs.text == rhs.text
  }
}

