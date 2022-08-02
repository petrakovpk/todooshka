//
//  CalendarDay.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import RxDataSources

struct CalendarDay: IdentifiableType, Equatable {
  
  // MARK: - Properties
  var date: Date
  var isSelected: Bool
  var completedTasksCount: Int
  var isEnabled: Bool
  
  // IdentifiableType
  var identity: Double {
    return date.timeIntervalSince1970
  }
  
  // MARK: - Equatable
  static func == (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
    return lhs.date == rhs.date
    && lhs.isSelected == rhs.isSelected
    && lhs.completedTasksCount == rhs.completedTasksCount
  }
}
