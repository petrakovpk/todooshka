//
//  TaskListSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import RxDataSources

struct TaskListSection: AnimatableSectionModelType {
  var header: String
  var items: [TaskListSectionItem]

  init(header: String, items: [TaskListSectionItem]) {
    self.header = header
    self.items = items
  }

  init(original: TaskListSection, items: [TaskListSectionItem]) {
    self = original
    self.items = items
  }
}

extension TaskListSection: IdentifiableType {
  var identity: String {
    return header
  }
}
