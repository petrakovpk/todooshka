//
//  Author.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.04.2023.
//

struct Author {
  let uid: String
  var nickname: String = ""
}

extension Author: Codable {
  enum CodingKeys: String, CodingKey {
    case uid, nickname
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    uid = try container.decode(String.self, forKey: .uid)
    nickname = try container.decode(String.self, forKey: .nickname)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uid, forKey: .uid)
    try container.encode(nickname, forKey: .nickname)
  }
}
