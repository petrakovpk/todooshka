//
//  Theme.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import CoreData
import Firebase
import Differentiator

struct Theme: IdentifiableType, Equatable {
  // MARK: - IdentifiableType
  var identity: String { UID }

  // MARK: - Properties
  let UID: String
  let name: String
}
