//
//  ReactionType.swift
//  DragoDo
//
//  Created by Pavel Petakov on 08.04.2023.
//

enum ReactionType: String {
    case upvote
    case downvote
    case skip
}

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
    case "skip":
      self = .skip
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

extension ReactionType: Equatable {
  static func == (lhs: ReactionType, rhs: ReactionType) -> Bool {
    lhs.rawValue == rhs.rawValue
  }
}
