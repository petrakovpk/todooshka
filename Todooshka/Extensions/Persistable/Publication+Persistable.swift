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
    self.text = entity.value(forKey: "text") as? String
    self.isPublic = entity.value(forKey: "isPublic") as? Bool ?? false
    self.created = created
    self.published = entity.value(forKey: "published") as? Date
    self.userUID = entity.value(forKey: "userUID") as? String
  }

  func update(_ entity: T) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(text, forKey: "text")
    entity.setValue(isPublic, forKey: "isPublic")
    entity.setValue(created, forKey: "created")
    entity.setValue(published, forKey: "published")
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

