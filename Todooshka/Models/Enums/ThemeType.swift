//
//  ThemeType.swift
//  DragoDo
//
//  Created by Pavel Petakov on 16.11.2022.
//

import Differentiator

enum ThemeType: String {
  case cooking
  case empty
  case health
  case sport
}

extension ThemeType: IdentifiableType {
  var identity: String { rawValue }
}
