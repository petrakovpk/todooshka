//
//  CalendarSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import RxDataSources

struct CalendarSectionModel: AnimatableSectionModelType {
  
  var identity: String {
    return header
  }
  
  var header: String
  var items: [CalendarDay]
  
  init(header: String, items: [CalendarDay]) {
    self.header = header
    self.items = items
  }
  
  init(original: CalendarSectionModel, items: [CalendarDay]) {
    self = original
    self.items = items
  }
}
