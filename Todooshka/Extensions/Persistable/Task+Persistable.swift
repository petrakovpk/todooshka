//
//  Task+Persistable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//

import CoreData
import RxSwift
import RxCocoa

extension Task: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    return "Task"
  }
  
  static var primaryAttributeName: String {
    return "uuid"
  }
  
  init?(entity: T) {
    guard
      let uuid = entity.value(forKey: "uuid") as? UUID,
      let created = entity.value(forKey: "created") as? Date,
      let description = entity.value(forKey: "desc") as? String,
      let index = entity.value(forKey: "index") as? Int,
      let kindUUID = entity.value(forKey: "kindUUID") as? UUID,
      let statusRawValue = entity.value(forKey: "statusRawValue") as? String,
      let status = TaskStatus(rawValue: statusRawValue),
      let text = entity.value(forKey: "text") as? String,
      let planned = entity.value(forKey: "planned") as? Date
    else { return nil }
    
    self.uuid = uuid
    self.created = created
    self.index = index
    self.kindUUID = kindUUID
    self.status = status
    self.text = text
    self.completed = entity.value(forKey: "closed") as? Date
    self.description = description
    self.planned = planned
    self.userUID = entity.value(forKey: "userUID") as? String
  }
  
  func update(_ entity: T) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(completed, forKey: "closed")
    entity.setValue(created, forKey: "created")
    entity.setValue(description, forKey: "desc")
    entity.setValue(index, forKey: "index")
    entity.setValue(kindUUID, forKey: "kindUUID")
    entity.setValue(planned, forKey: "planned")
    entity.setValue(status.rawValue, forKey: "statusRawValue")
    entity.setValue(text, forKey: "text")
    entity.setValue(userUID, forKey: "userUID")
  }
  
  func save(_ entity: T) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
