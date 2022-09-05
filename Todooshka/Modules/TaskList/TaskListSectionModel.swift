//
//  TaskListSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import RxDataSources

struct TaskListSectionModel: AnimatableSectionModelType {
  
  var identity: String { header }
  
  var header: String
  var mode: TaskCellMode
  var items: [TaskListSectionItem]
  
  init(header: String, mode: TaskCellMode, items: [TaskListSectionItem]) {
    self.header = header
    self.mode = mode
    self.items = items
  }
  
  init(original: TaskListSectionModel, items: [TaskListSectionItem]) {
    self = original
    self.items = items
  }
}
