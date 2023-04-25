//
//  TaskListSectionItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 02.09.2022.
//

import RxDataSources

struct TaskListSectionItem: IdentifiableType, Equatable {
  let task: Task
  let kind: Kind?
  var mode: ListCellMode

  var identity: String {
    task.uuid.uuidString + (kind?.uuid.uuidString ?? "")
  }

  static func == (lhs: TaskListSectionItem, rhs: TaskListSectionItem) -> Bool {
    lhs.task == rhs.task
    && lhs.kind == rhs.kind
  }
}
