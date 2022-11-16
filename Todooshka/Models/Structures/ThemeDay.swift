//
//  ThemeDay.swift
//  DragoDo
//
//  Created by Pavel Petakov on 10.11.2022.
//

import Differentiator

enum ThemeDayNumber: CaseIterable {
  case first
  case second
  case third
  case fourth
  case fifth
  case sixth
  case seventh
}

struct ThemeDay: Equatable {
  let UID: String
  let goal: String
  let weekDay: ThemeDayNumber
}

// MARK: - IdentifiableType
extension ThemeDay: IdentifiableType {
  var identity: String { UID }
}

