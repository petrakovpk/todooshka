//
//  Date.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.08.2021.

import Foundation



extension Date {
  var startOfDay: Date {
    Calendar.current.startOfDay(for: self)
  }
  
  var startOfWeek: Date {
    Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self).date!
  }
  
  var startOfMonth: Date {
    let components = calendar.dateComponents([.year, .month], from: self)
    return Calendar.current.date(from: components)!
  }

  var endOfDay: Date {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfDay)!
  }
  
  var roundToTheBottomMinute: Date {
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
    return Calendar.current.date(from: components)!
  }

  var endOfMonth: Date {
    var components = DateComponents()
    components.month = 1
    components.second = -1
    return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
  }

  func isMonday() -> Bool {
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents([.weekday], from: self)
    return components.weekday == 2
  }
  
  /// Returns the amount of months from another date
  /// https://stackoverflow.com/questions/27182023/getting-the-difference-between-two-dates-months-days-hours-minutes-seconds-in
  func months(from date: Date) -> Int {
    return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
  }
  
}
