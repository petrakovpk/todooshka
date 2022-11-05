//
//  CalendarSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import RxDataSources

struct CalendarSection: AnimatableSectionModelType {

  var identity: Double {
    switch type {
    case .year(let year):
      return year.double
    case .month(let startOfMonth):
      return startOfMonth.timeIntervalSince1970
    }
  }

  var startOfPeriod: Date {
    switch type {
    case .year(let year):
      return Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1)) ?? Date()
    case .month(let startOfMonth):
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
