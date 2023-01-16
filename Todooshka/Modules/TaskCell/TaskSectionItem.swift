//
//  TaskSectionItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.01.2023.
//

import RxDataSources


enum TaskCellItemType {
  case text
  case textAndImage
}

struct TaskSectionItem: IdentifiableType, Equatable {
  let type: TaskCellItemType
  let task: Task

  var identity: String { task.UID }

  static func == (lhs: TaskSectionItem, rhs: TaskSectionItem) -> Bool {
    lhs.task == rhs.task
    && lhs.type == rhs.type
  }
}
