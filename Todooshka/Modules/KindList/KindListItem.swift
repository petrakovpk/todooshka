//
//  KindListItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 25.09.2022.
//

import RxDataSources

struct KindListItem {
  let kind: Kind
  let cellMode: ListCellMode
}

extension KindListItem: IdentifiableType {
  var identity: String {
    return kind.uuid.uuidString
  }
}

extension KindListItem: Equatable {
  static func == (lhs: KindListItem, rhs: KindListItem) -> Bool {
    lhs.identity == rhs.identity
  }
}
