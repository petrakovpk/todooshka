//
//  QuestCategoryItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.05.2023.
//


import RxDataSources

enum PublicKindItemType {
  case empty
  case kind(kind: PublicKind)
}

extension PublicKindItemType: Equatable {
  static func == (lhs: PublicKindItemType, rhs: PublicKindItemType) -> Bool {
    switch (lhs, rhs) {
    case (.empty, .empty):
      return true
    case (.kind(let lKind), .kind(let rKind)):
      return lKind == rKind
    default:
      return false
    }
  }
}

struct PublicKindItem {
  let publicKindItemType: PublicKindItemType
  let isSelected: Bool
}

extension PublicKindItem: IdentifiableType {
  var identity: String {
    switch self.publicKindItemType {
    case .empty:
      return "empty"
    case .kind(let kind):
      return kind.identity
    }
  }
}

extension PublicKindItem: Equatable {
  static func == (lhs: PublicKindItem, rhs: PublicKindItem) -> Bool {
    lhs.publicKindItemType == rhs.publicKindItemType &&
    lhs.isSelected == rhs.isSelected
  }
}

