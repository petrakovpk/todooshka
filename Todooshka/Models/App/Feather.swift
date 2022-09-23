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

// MARK: - Persistable
extension Feather: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    return "Feather"
  }
  
  static var primaryAttributeName: String {
    return "uid"
  }
  
  init(entity: T) {
    UID = entity.value(forKey: "uid") as! String
    created = entity.value(forKey: "created") as! Date
    taskUID = entity.value(forKey: "taskUID") as! String
    isSpent = entity.value(forKey: "isSpent") as! Bool
  }
  
  func update(_ entity: T) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(created, forKey: "created")
    entity.setValue(taskUID, forKey: "taskUID")
    entity.setValue(isSpent, forKey: "isSpent")

    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
