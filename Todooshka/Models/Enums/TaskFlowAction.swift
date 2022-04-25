//
//  TaskFlowAction.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.04.2022.
//

import Foundation

enum TaskFlowAction {
  case create(status: TaskStatus, closed: Date?)
  case show(task: Task)
}
