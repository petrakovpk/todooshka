//
//  CalendarSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import RxDataSources

struct CalendarSection: AnimatableSectionModelType {
  var year: Int
  var month: Int
  var items: [CalendarItem]
  
  var identity: String {
    year.string + month.string
  }
  
  var startDate: Date {
    Date(year: year, month: month, day: 1)!
  }
  
  var endDate: Date {
    startDate.endOfMonth
  }

  init(year: Int, month: Int, items: [CalendarItem]) {
    self.year = year
    self.month = month
    self.items = items
  }

  init(original: CalendarSection, items: [CalendarItem]) {
    self = original
    self.items = items
  }
}
