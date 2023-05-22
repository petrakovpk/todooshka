//
//  KindCellItem.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.05.2022.
//

import RxDataSources

enum KindSectionItemType {
  case emptyKind
  case kind(kind: Kind)
}

extension KindSectionItemType: Equatable {
  
}

struct KindSectionItem {
  let kindSectionItemType: KindSectionItemType
  let isSelected: Bool
}

extension KindSectionItem: IdentifiableType {
  var identity: String {
    switch kindSectionItemType {
    case .emptyKind:
      return "emptyKind"
    case .kind(let kind):
      return kind.identity
    }
  }
}

extension KindSectionItem: Equatable {
  static func == (lhs: KindSectionItem, rhs: KindSectionItem) -> Bool {
    lhs.isSelected == rhs.isSelected &&
    lhs.kindSectionItemType == rhs.kindSectionItemType
  }
}
