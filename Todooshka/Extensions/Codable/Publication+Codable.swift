//
//  Publication+Codable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 25.05.2023.
//

import Foundation

extension Publication: Codable {
  enum CodingKeys: String, CodingKey {
    case uuid, text, isPublic, created, published, userUID = "userUid"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    uuid = try container.decode(UUID.self, forKey: .uuid)
    text = try container.decode(String.self, forKey: .text)
    isPublic = try container.decode(Bool.self, forKey: .isPublic)
    created = try container.decode(Date.self, forKey: .created)
    published = try container.decode(Date.self, forKey: .published)
    userUID = try container.decode(String.self, forKey: .userUID)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uuid, forKey: .uuid)
    try container.encode(text, forKey: .text)
    try container.encode(isPublic, forKey: .isPublic)
    try container.encode(created, forKey: .created)
    try container.encode(published, forKey: .published)
    try container.encode(userUID, forKey: .userUID)
  }
}
