//
//  TaskListSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import RxDataSources

struct TaskListSection: AnimatableSectionModelType {
  var identity: String { mode.rawValue }

  var header: String
  var mode: TaskCellMode
  var items: [TaskListSectionItem]

  init(header: String, mode: TaskCellMode, items: [TaskListSectionItem]) {
    self.header = header
    self.mode = mode
    self.items = items
  }

  init(original: TaskListSection, items: [TaskListSectionItem]) {
    self = original
    self.items = items
  }
}
