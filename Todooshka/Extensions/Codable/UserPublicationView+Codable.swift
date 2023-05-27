//
//  UserPublicationView+Cosable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.05.2023.
//


import UIKit

extension UserPublicationView: Codable {
  enum CodingKeys: String, CodingKey {
    case publicationUUID = "publicationUuid", userUID = "userUid"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    publicationUUID = try container.decode(UUID.self, forKey: .publicationUUID)
    userUID = try container.decode(String.self, forKey: .userUID)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(publicationUUID, forKey: .publicationUUID)
    try container.encode(userUID, forKey: .userUID)
  }
}
