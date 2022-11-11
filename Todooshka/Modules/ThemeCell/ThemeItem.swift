//
//  ThemeItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import RxDataSources

enum ThemeItem {
  case theme(theme: Theme)
  case plusButton
}

// MARK: - Identity
extension ThemeItem: IdentifiableType {
  var identity: String {
    switch self {
    case .theme(let theme):
      return theme.UID
    case .plusButton:
      return "plusButton"
    }
  }
}

// MARK: - Equatable
extension ThemeItem: Equatable {
  static func == (lhs: ThemeItem, rhs: ThemeItem) -> Bool {
    switch (lhs, rhs) {
    case let (.theme(leftTheme), .theme(rightTheme) ):
      return leftTheme.UID == rightTheme.UID
    case (.theme, .plusButton):
      return false
    case (.plusButton, .theme):
      return false
    case (.plusButton, .plusButton):
      return true
    }
  }
}
