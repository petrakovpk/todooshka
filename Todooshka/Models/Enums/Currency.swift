//
//  Currency.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

enum Currency: String {
  // Перо
  case feather = "Feather"
  // Бриллиант
  case diamond = "Diamond"
  // index
  var index: Int {
    switch self {
    case .feather:
      return 0
    case .diamond:
      return 1
    }
  }
}
