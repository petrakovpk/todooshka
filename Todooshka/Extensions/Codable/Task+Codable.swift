//
//  Task+Codable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 15.04.2023.
//

import Foundation

extension Task: Codable {
  enum CodingKeys: String, CodingKey {
    case uuid, text, description, status, index, created, planned, completed, kindUUID = "kindUuid", userUID = "userUid", imageUUID = "imageUuid"
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
    kindUUID = try container.decode(UUID.self, forKey: .kindUUID)
    userUID = try container.decodeIfPresent(String.self, forKey: .userUID)
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
    try container.encodeIfPresent(kindUUID, forKey: .kindUUID)
    try container.encodeIfPresent(userUID, forKey: .userUID)
  }
}

extension Task: Equatable {
  static func == (lhs: Task, rhs: Task) -> Bool {
    return lhs.uuid == rhs.uuid &&
    lhs.text == rhs.text &&
    lhs.description == rhs.description &&
    lhs.status == rhs.status &&
    lhs.kindUUID == rhs.kindUUID &&
    lhs.created == rhs.created &&
    lhs.completed == rhs.completed &&
    lhs.planned == rhs.planned &&
    lhs.index == rhs.index &&
    lhs.userUID == rhs.userUID
  }
}
