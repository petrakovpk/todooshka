//
//  CalendarDay.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import RxDataSources

struct CalendarItem: IdentifiableType, Equatable {
  let date: Date
  let isSelected: Bool
  let completedTasksCount: Int
  let plannedTasksCount: Int
  
  var identity: String {
    date.timeIntervalSince1970.string + isSelected.string + completedTasksCount.string + plannedTasksCount.string
  }

  // MARK: - Equatable
  static func == (lhs: CalendarItem, rhs: CalendarItem) -> Bool {
    return lhs.identity == rhs.identity
  }
}
