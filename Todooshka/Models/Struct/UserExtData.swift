//
//  UserExtData.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.04.2023.
//

import FirebaseAuth
import UIKit

struct UserExtData {
  let userUID: String
  var nickName: String?
  var image: UIImage?
}

extension UserExtData: Equatable {
  static func == (lhs: UserExtData, rhs: UserExtData) -> Bool {
    lhs.userUID == rhs.userUID &&
    lhs.nickName == rhs.nickName &&
    lhs.image == rhs.image
  }
}

extension UserExtData: Codable {
  enum CodingKeys: String, CodingKey {
    case userUID, nickName, imageData
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    userUID = try container.decode(String.self, forKey: .userUID)
    nickName = try container.decode(String.self, forKey: .nickName)
    image = try UIImage(data: container.decode(Data.self, forKey: .imageData))
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(userUID, forKey: .userUID)
    try container.encode(nickName, forKey: .nickName)
    try container.encode(image?.pngData(), forKey: .imageData)
  }
}

