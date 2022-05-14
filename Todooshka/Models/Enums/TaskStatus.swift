//
//  TaskStatus.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//

enum TaskStatus: String, Codable {
  case Draft = "Draft"
  case InProgress = "InProgress"
  case Completed = "Completed"
  case Deleted = "Deleted"
  case Idea = "Idea"
}
