//
//  Reaction+Codable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 26.05.2023.
//

import Foundation

extension Reaction: Codable {
  enum CodingKeys: String, CodingKey {
    case uuid, userUID = "userUid", publicationUUID = "publicationUuid", reactionType
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    uuid = try container.decode(UUID.self, forKey: .uuid)
    userUID = try container.decode(String.self, forKey: .userUID)
    publicationUUID = try container.decode(UUID.self, forKey: .publicationUUID)
    reactionType = try container.decode(ReactionType.self, forKey: .reactionType)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uuid, forKey: .uuid)
    try container.encode(userUID, forKey: .userUID)
    try container.encode(publicationUUID, forKey: .publicationUUID)
    try container.encode(reactionType, forKey: .reactionType)
  }
}

