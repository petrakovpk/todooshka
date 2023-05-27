//
//  ReactionType+Codable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 26.05.2023.
//

import Foundation

extension ReactionType: Codable {
  // Реализация метода для декодирования
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let typeString = try container.decode(String.self)
    
    switch typeString {
    case "upvote":
      self = .upvote
    case "downvote":
      self = .downvote
    default:
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown reaction type: \(typeString)")
    }
  }
  
  // Реализация метода для кодирования
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}
