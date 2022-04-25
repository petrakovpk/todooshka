//
//  TaskStatus.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//

enum TaskStatus: String, Codable {
  case New = "new"
  case Created = "created"
  case Completed = "completed"
  case Deleted = "deleted"
  case Idea = "idea"
}
