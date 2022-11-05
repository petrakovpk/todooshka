//
//  ThemeItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import RxDataSources

struct ThemeItem: IdentifiableType, Equatable {

  // MARK: - Identity
  var identity: String {
    theme.UID
  }

  let theme: Theme

  // MARK: - Equatable
  static func == (lhs: ThemeItem, rhs: ThemeItem) -> Bool {
     lhs.theme == rhs.theme
  }
}
