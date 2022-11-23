//
//  ThemeTypeItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 21.11.2022.
//

import RxDataSources

struct ThemeTypeItem {
  let type: ThemeType
  var isSelected: Bool
}

// MARK: - Identity
extension ThemeTypeItem: IdentifiableType {
  var identity: String {
    type.rawValue + isSelected.string
  }
}

// MARK: - Equatable
extension ThemeTypeItem: Equatable {
  static func == (lhs: ThemeTypeItem, rhs: ThemeTypeItem) -> Bool {
    lhs.type.rawValue == rhs.type.rawValue &&
    lhs.isSelected == rhs.isSelected
  }
}

