//
//  TaskStatus.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//

import Foundation

enum TaskStatus:String {
  case Completed = "Completed"
  case Deleted = "Deleted"
  case Draft = "Draft"
  case Idea = "Idea"
  case InProgress = "InProgress"
}
//
//extension TaskStatus: RawRepresentable {
//
//    public typealias RawValue = String
//
//    /// Failable Initalizer
//    public init?(rawValue: RawValue) {
//        switch rawValue {
//        case "Deleted":       self = .Deleted
//        case "Draft":         self = .Draft
//        case "Idea":          self = .Idea
//        case "InProgress":    self = .InProgress
//        case "Completed":     self = .Completed(date: Date())
//        default: return nil
//        }
//    }
//
//    /// Backing raw value
//    public var rawValue: RawValue {
//        switch self {
//        case .Completed(_):  return "Completed"
//        case .Deleted:       return "Deleted"
//        case .Draft:         return "Draft"
//        case .Idea:          return "Idea"
//        case .InProgress:    return "InProgress"
//        }
//    }
//}
//
