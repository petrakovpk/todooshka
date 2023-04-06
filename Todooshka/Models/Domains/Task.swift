//
//  Task.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 20.05.2021.
//

import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import RxDataSources

struct Task {
  let uuid: UUID
  var text: String = ""
  var description: String = ""
  var status: TaskStatus
  var index: Int = 0
  var created = Date()
  var planned = Date().endOfDay
  var completed: Date?
  var kindOfTaskUID: String?
  var userUID: String? = Auth.auth().currentUser?.uid
  var imageUUID: UUID?
  
  var secondsLeft: Double {
    max(planned.timeIntervalSince1970 - Date().startOfDay.timeIntervalSince1970, 0)
  }
}

extension Task: Codable {
  enum CodingKeys: String, CodingKey {
    case uuid, text, description, status, index, created, planned, completed, kindOfTaskUID, userUID = "userUid", imageUUID = "imageUuid"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    uuid = try container.decode(UUID.self, forKey: .uuid)
    text = try container.decode(String.self, forKey: .text)
    description = try container.decode(String.self, forKey: .description)
    status = try container.decode(TaskStatus.self, forKey: .status)
    index = try container.decode(Int.self, forKey: .index)
    created = try container.decode(Date.self, forKey: .created)
    planned = try container.decode(Date.self, forKey: .planned)
    completed = try container.decodeIfPresent(Date.self, forKey: .completed)
    kindOfTaskUID = try container.decodeIfPresent(String.self, forKey: .kindOfTaskUID)
    userUID = try container.decodeIfPresent(String.self, forKey: .userUID)
    imageUUID = try container.decodeIfPresent(UUID.self, forKey: .imageUUID)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uuid, forKey: .uuid)
    try container.encode(text, forKey: .text)
    try container.encode(description, forKey: .description)
    try container.encode(status, forKey: .status)
    try container.encode(index, forKey: .index)
    try container.encode(created, forKey: .created)
    try container.encode(planned, forKey: .planned)
    try container.encodeIfPresent(completed, forKey: .completed)
    try container.encodeIfPresent(kindOfTaskUID, forKey: .kindOfTaskUID)
    try container.encodeIfPresent(userUID, forKey: .userUID)
    try container.encodeIfPresent(imageUUID, forKey: .imageUUID)
  }
}

extension Task: Equatable {
  static func == (lhs: Task, rhs: Task) -> Bool {
    return lhs.uuid == rhs.uuid &&
    lhs.text == rhs.text &&
    lhs.description == rhs.description &&
    lhs.status == rhs.status &&
    lhs.kindOfTaskUID == rhs.kindOfTaskUID &&
    lhs.created == rhs.created &&
    lhs.completed == rhs.completed &&
    lhs.planned == rhs.planned &&
    lhs.index == rhs.index &&
    lhs.userUID == rhs.userUID &&
    lhs.imageUUID == rhs.imageUUID
  }
}

extension Task: IdentifiableType {
  var identity: String { uuid.uuidString }
}

extension Task: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String { "Task" }
  static var primaryAttributeName: String { "uuid" }
  
  init?(entity: T) {
    guard
      let uuid = entity.value(forKey: "uuid") as? UUID,
      let created = entity.value(forKey: "created") as? Date,
      let description = entity.value(forKey: "desc") as? String,
      let index = entity.value(forKey: "index") as? Int,
      let kindOfTaskUID = entity.value(forKey: "kindOfTaskUID") as? String,
      let statusRawValue = entity.value(forKey: "statusRawValue") as? String,
      let status = TaskStatus(rawValue: statusRawValue),
      let text = entity.value(forKey: "text") as? String,
      let planned = entity.value(forKey: "planned") as? Date
    else { return nil }
    
    self.uuid = uuid
    self.created = created
    self.index = index
    self.kindOfTaskUID = kindOfTaskUID
    self.status = status
    self.text = text
    self.completed = entity.value(forKey: "closed") as? Date
    self.description = description
    self.planned = planned
    self.userUID = entity.value(forKey: "userUID") as? String
    self.imageUUID = entity.value(forKey: "imageUUID") as? UUID
  }
  
  func update(_ entity: T) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(completed, forKey: "closed")
    entity.setValue(created, forKey: "created")
    entity.setValue(description, forKey: "desc")
    entity.setValue(index, forKey: "index")
    entity.setValue(kindOfTaskUID, forKey: "kindOfTaskUID")
    entity.setValue(planned, forKey: "planned")
    entity.setValue(status.rawValue, forKey: "statusRawValue")
    entity.setValue(text, forKey: "text")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(imageUUID, forKey: "imageUUID")
  }
  
  func save(_ entity: T) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
