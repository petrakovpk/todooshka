//
//  Currency.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

enum Currency: String {
  // Перо
  case Feather = "Feather"
  // Бриллиант
  case Diamond = "Diamond"
  // index
  var index: Int {
    switch self {
    case .Feather:
      return 0
    case .Diamond:
      return 1
    }
  }
}
