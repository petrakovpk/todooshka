//
//  Reaction.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import CoreData
import Firebase

struct Reaction {
  let uuid: UUID
  let userUID: String
  let taskUUID: UUID
  let type: ReactionType
}

extension Reaction: Equatable {
  static func == (lhs: Reaction, rhs: Reaction) -> Bool {
    lhs.uuid == rhs.uuid
    && lhs.userUID == rhs.userUID
    && lhs.taskUUID == rhs.taskUUID
    && lhs.type == rhs.type
  }
}

extension Reaction: Codable {
  enum CodingKeys: String, CodingKey {
    case uuid, userUID = "userUid", taskUUID = "taskUuid", type
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    uuid = try container.decode(UUID.self, forKey: .uuid)
    userUID = try container.decode(String.self, forKey: .userUID)
    taskUUID = try container.decode(UUID.self, forKey: .taskUUID)
    type = try container.decode(ReactionType.self, forKey: .type)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uuid, forKey: .uuid)
    try container.encode(userUID, forKey: .userUID)
    try container.encode(taskUUID, forKey: .taskUUID)
    try container.encode(type, forKey: .type)
  }
}

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
      let taskUUID = entity.value(forKey: "taskUUID") as? UUID,
      let typeRawValue = entity.value(forKey: "typeRawValue") as? String,
      let type = ReactionType(rawValue: typeRawValue)
    else { return nil }
    
    self.uuid = uuid
    self.userUID = userUID
    self.taskUUID = taskUUID
    self.type = type
  }
  
  func update(_ entity: NSManagedObject) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(taskUUID, forKey: "taskUUID")
    entity.setValue(type.rawValue, forKey: "typeRawValue")
  }
  
  func save(_ entity: NSManagedObject) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
