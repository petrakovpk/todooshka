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
    return lhs.task.UID == rhs.task.UID
    && lhs.task.status.rawValue == rhs.task.status.rawValue
    && lhs.kindOfTask.UID == rhs.kindOfTask.UID

  }
  
}
