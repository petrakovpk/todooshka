//
//  TaskListSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import RxDataSources

struct TaskListSectionModel: AnimatableSectionModelType {
  
  var identity: String {
    return header
  }
  
  var header: String
  var mode: TaskCellMode
  var items: [Task]
  
  init(header: String, mode: TaskCellMode, items: [Task]) {
    self.header = header
    self.mode = mode
    self.items = items
  }
  
  init(original: TaskListSectionModel, items: [Task]) {
    self = original
    self.items = items
  }
}
