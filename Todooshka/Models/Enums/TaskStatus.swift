//
//  TaskStatus.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//

import Foundation

enum TaskStatus: String {
  case inProgress
  case idea
  case completed
  case published
  case deleted
  case archive
}

extension TaskStatus: Codable {
  // Реализация метода для декодирования
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let statusString = try container.decode(String.self)
    
    switch statusString {
    case "in_progress":
      self = .inProgress
    case "idea":
      self = .idea
    case "completed":
      self = .completed
    case "published":
      self = .published
    case "deleted":
      self = .deleted
    case "archive":
      self = .archive
    default:
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown task status: \(statusString)")
    }
  }
  
  // Реализация метода для кодирования
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}
