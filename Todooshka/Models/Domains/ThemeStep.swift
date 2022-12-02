//
//  ThemeStep.swift
//  DragoDo
//
//  Created by Pavel Petakov on 10.11.2022.
//

import Differentiator

struct ThemeStep: Equatable {
  let UID: String
  let goal: String
}

// MARK: - IdentifiableType
extension ThemeStep: IdentifiableType {
  var identity: String { UID }
}

