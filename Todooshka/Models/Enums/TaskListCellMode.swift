//
//  TaskListCellMode.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 01.04.2022.
//

import Foundation

enum ListCellMode: String {
  // общие для task и kind
  case empty
  case repeatButton
  // для task
  case blueLine
  case redLineAndTime
  case time
  case likes
  // для kind
  case withRightImage
}
