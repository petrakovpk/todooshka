//
//  UserDeafults.swift
//  DragoDo
//
//  Created by Pavel Petakov on 16.01.2023.
//

import Foundation

extension DateFormatter {
  static let midDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "dd MMM"
    return formatter
  }()
  
  static let midTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "HH:mm"
    return formatter
  }()
}
