//
//  TaskListSectionItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 02.09.2022.
//

import RxDataSources

struct TaskListSectionItem: IdentifiableType, Equatable {
  
  let task: Task
  let type: TaskType
  
  var identity: String { task.UID + type.UID }
  
}
