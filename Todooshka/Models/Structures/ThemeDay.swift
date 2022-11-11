//
//  ThemeDay.swift
//  DragoDo
//
//  Created by Pavel Petakov on 10.11.2022.
//

import Differentiator

enum Weekday: CaseIterable {
  case monday
  case tuesday
  case wednesday
  case thursday
  case friday
  case saturday
  case sunday
}

struct ThemeDay: Equatable {
  let UID: String
  let goal: String
  let weekDay: Weekday
}

// MARK: - IdentifiableType
extension ThemeDay: IdentifiableType {
  var identity: String { UID }
}

