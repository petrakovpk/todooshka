//
//  CalendarSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import RxDataSources

enum CalendarSectionType {
  case Month, Year
}

struct CalendarSectionModel: AnimatableSectionModelType {
  
  var identity: String {
    year.string + month.string
  }
  
  var type: CalendarSectionType
  var year: Int
  var month: Int
  var items: [CalendarDay]
  
//  var monthName: String {
//    DateFormatter().standaloneMonthSymbols[self.month - 1]
//  }
  
  init(type: CalendarSectionType, year: Int, month: Int, items: [CalendarDay]) {
    self.type = type
    self.year = year
    self.month = month
    self.items = items
  }
  
  init(original: CalendarSectionModel, items: [CalendarDay]) {
    self = original
    self.items = items
  }
}
