//
//  Publication+Persistable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 08.05.2023.
//

import CoreData
import RxSwift
import RxCocoa

extension Publication: Persistable {
  var identity: String {
    uuid.uuidString
  }
  
  typealias T = NSManagedObject

  static var entityName: String {
    return "Publication"
  }

  static var primaryAttributeName: String {
    return "uuid"
  }

  init?(entity: T) {
    guard
      let uuid = entity.value(forKey: "uuid") as? UUID,
      let created = entity.value(forKey: "created") as? Date
    else { return nil }

    self.uuid = uuid
    self.created = created
    self.userUID = entity.value(forKey: "userUID") as? String
    self.taskUUID = entity.value(forKey: "taskUUID") as? UUID
    self.text = entity.value(forKey: "text") as? String
    self.published = entity.value(forKey: "published") as? Date
    self.publicKindUUID = entity.value(forKey: "publicKindUUID") as? UUID
    
    if let statusRawValue = entity.value(forKey: "statusRawValue") as? String,
       let status = PublicationStatus(rawValue: statusRawValue) {
      self.status = status
    }
  }

  func update(_ entity: T) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(taskUUID, forKey: "taskUUID")
    entity.setValue(text, forKey: "text")
    entity.setValue(status.rawValue, forKey: "statusRawValue")
    entity.setValue(created, forKey: "created")
    entity.setValue(published, forKey: "published")
    entity.setValue(publicKindUUID, forKey: "publicKindUUID")
  }

  func save(_ entity: T) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}

