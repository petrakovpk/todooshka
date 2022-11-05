//
//  CalendarDay.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import RxDataSources

enum CalendarItemType {
  case empty
  case day(date: Date, isSelected: Bool, completedTasksCount: Int, plannedTasksCount: Int)
}

struct CalendarItem: IdentifiableType, Equatable {

  // IdentifiableType
  var identity: String {
    switch type {
    case .empty:
      return "Empty"
    case .day(let date, let isSelected, let completedTasksCount, let plannedTasksCount):
      return date.timeIntervalSince1970.string + isSelected.string + completedTasksCount.string + plannedTasksCount.string
    }
  }

  var type: CalendarItemType

  // MARK: - Equatable
  static func == (lhs: CalendarItem, rhs: CalendarItem) -> Bool {
    return lhs.identity == rhs.identity
  }
}
