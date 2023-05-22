//
//  Image+Persistable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 12.05.2023.
//

import CoreData

extension Image: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    "Image"
  }
  
  static var primaryAttributeName: String {
    "uuid"
  }
  
  var identity: String {
    self.uuid.uuidString
  }
  
  init?(entity: NSManagedObject) {
    guard
      let uuid = entity.value(forKey: "uuid") as? UUID,
      let imageData = entity.value(forKey: "imageData") as? Data
    else { return nil }
    
    self.uuid = uuid
    self.imageData = imageData
  }
  
  func update(_ entity: NSManagedObject) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(imageData, forKey: "imageData")
  }
  
  func save(_ entity: NSManagedObject) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}

