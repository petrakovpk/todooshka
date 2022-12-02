//
//  Feather.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//

import CoreData
import Foundation
import Differentiator

struct Feather: IdentifiableType {
  let UID: String
  let created: Date
  let taskUID: String
  var isSpent: Bool

  var identity: String { UID }

  // MARK: - Init
  init(UID: String, created: Date, taskUID: String, isSpent: Bool) {
    self.UID = UID
    self.created = created
    self.taskUID = taskUID
    self.isSpent = isSpent
  }
}
