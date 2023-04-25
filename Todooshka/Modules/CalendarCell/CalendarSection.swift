//
//  CalendarSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import RxDataSources

struct CalendarSection: AnimatableSectionModelType {
  var month: Date
  var items: [CalendarItem]

  init(month: Date, items: [CalendarItem]) {
    self.month = month
    self.items = items
  }

  init(original: CalendarSection, items: [CalendarItem]) {
    self = original
    self.items = items
  }
}

extension CalendarSection: IdentifiableType {
  var identity: String {
    return month.string()
  }
}

