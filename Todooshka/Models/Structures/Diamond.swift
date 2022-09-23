//
//  Diamond.swift
//  Todooshka
//
//  Created by Pavel Petakov on 19.09.2022.
//

import CoreData
import Foundation
import Differentiator

struct Diamond: IdentifiableType {
  let UID: String
  let created: Date
  
  var identity: String { UID }
  
  // MARK: - Init
  init(UID: String, created: Date) {
    self.UID = UID
    self.created = created
  }
}

// MARK: - Persistable
extension Diamond: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    return "Diamond"
  }
  
  static var primaryAttributeName: String {
    return "uid"
  }
  
  init(entity: T) {
    UID = entity.value(forKey: "uid") as! String
    created = entity.value(forKey: "created") as! Date
  }
  
  func update(_ entity: T) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(created, forKey: "created")

    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}

