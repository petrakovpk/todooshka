//
//  Reaction+Persistable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 26.05.2023.
//

import CoreData

extension Reaction: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    "Reaction"
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
      let userUID = entity.value(forKey: "userUID") as? String,
      let publicationUUID = entity.value(forKey: "publicationUUID") as? UUID,
      let typeRawValue = entity.value(forKey: "typeRawValue") as? String,
      let reactionType = ReactionType(rawValue: typeRawValue)
    else { return nil }
    
    self.uuid = uuid
    self.userUID = userUID
    self.publicationUUID = publicationUUID
    self.reactionType = reactionType
  }
  
  func update(_ entity: NSManagedObject) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(publicationUUID, forKey: "publicationUUID")
    entity.setValue(reactionType.rawValue, forKey: "typeRawValue")
  }
  
  func save(_ entity: NSManagedObject) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
