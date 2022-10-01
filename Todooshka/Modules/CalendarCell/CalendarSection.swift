//
//  CalendarSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import RxDataSources

enum CalendarSectionType {
  case Month(startOfMonth: Date)
  case Year(year: Int)
}

struct CalendarSection: AnimatableSectionModelType {
  
  var identity: Double {
    switch type {
    case .Year(let year):
      return year.double
    case .Month(let startOfMonth):
      return startOfMonth.timeIntervalSince1970
    }
  }
  
  var startOfPeriod: Date {
    switch type {
    case .Year(let year):
      return Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1)) ?? Date()
    case .Month(let startOfMonth):
      return startOfMonth
    }
  }
  
  var type: CalendarSectionType
  var items: [CalendarItem]

  init(type: CalendarSectionType, items: [CalendarItem]) {
    self.type = type
    self.items = items
  }
  
  init(original: CalendarSection, items: [CalendarItem]) {
    self = original
    self.items = items
  }
}
