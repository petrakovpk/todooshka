//
//  KindCellItem.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.05.2022.
//

import RxDataSources

struct KindSectionItem {
  let kind: Kind
  let isSelected: Bool
}

extension KindSectionItem: IdentifiableType {
  var identity: String {
    return kind.uuid.uuidString
  }
}

extension KindSectionItem: Equatable {
  static func == (lhs: KindSectionItem, rhs: KindSectionItem) -> Bool {
    lhs.isSelected == rhs.isSelected &&
    lhs.kind == rhs.kind
  }
}
