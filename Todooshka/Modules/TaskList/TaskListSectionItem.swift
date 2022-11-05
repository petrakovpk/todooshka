//
//  TaskListSectionItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 02.09.2022.
//

import RxDataSources

struct TaskListSectionItem: IdentifiableType, Equatable {

  let task: Task
  let kindOfTask: KindOfTask

  var identity: String {
    task.UID + kindOfTask.UID
  }

  static func == (lhs: TaskListSectionItem, rhs: TaskListSectionItem) -> Bool {
    return lhs.task == rhs.task
    && lhs.kindOfTask == rhs.kindOfTask
  }

}
