//
//  Theme.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import Differentiator

struct Theme: Equatable {
  let UID: String
  let name: String
  let themeWeeks: [ThemeWeek]
}

// MARK: - IdentifiableType
extension Theme: IdentifiableType {
  var identity: String { UID }
}
