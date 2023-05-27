//
//  UserExtData+Codable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 26.05.2023.
//

import UIKit

extension UserExtData: Codable {
  enum CodingKeys: String, CodingKey {
    case uid, nickname, image
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    uid = try container.decode(String.self, forKey: .uid)
    nickname = try container.decode(String.self, forKey: .nickname)
    image = try UIImage(data: container.decode(Data.self, forKey: .image))
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uid, forKey: .uid)
    try container.encode(nickname, forKey: .nickname)
    try container.encode(image?.pngData(), forKey: .image)
  }
}

