//
//  CalendarSectionType.swift
//  DragoDo
//
//  Created by Pavel Petakov on 03.11.2022.
//

import Foundation

enum CalendarSectionType {
  case month(startOfMonth: Date)
  case year(year: Int)
}
