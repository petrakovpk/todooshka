//
//  KindOfTaskStatus.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

enum KindOfTaskStatus: String, Codable {
  case active = "active"
  case deleted = "deleted" // удален и можно посмотреть в спсике удаленных типов
}
