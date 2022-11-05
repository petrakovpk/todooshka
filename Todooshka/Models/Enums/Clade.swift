//
//  Clade.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import UIKit

enum Clade: String {

  // Курица
  case chiken = "курица"
  // Пингвин
  case penguin = "пингвин"
  // Страус
  case ostrich = "страус"
  // Попугай
  case parrot = "попугай"
  // Орел
  case eagle = "орел"
  // Сова
  case owl = "сова"
  // Дракон
  case dragon = "дракон"

  // level
  var level: Int {
    switch self {
    case .chiken: return 1
    case .ostrich: return 2
    case .owl: return 3
    case .parrot: return 4
    case .penguin: return 5
    case .eagle: return 6
    case .dragon: return 7
    }
  }

  var gender: Gender {
    switch self {
    case .chiken, .owl:
      return .female
    case .dragon, .eagle, .ostrich, .parrot, .penguin:
      return .male
    }
  }

  // text
  var text: String {
    switch self {
    case .chiken: return "Ряба"
    case .ostrich: return "Страус"
    case .owl: return "Сова"
    case .parrot: return "Попугай"
    case .penguin: return "Пингвин"
    case .eagle: return "Орел"
    case .dragon: return "Дракон"
    }
  }

  // init
  init(level: Int) {
    switch level {
    case 1: self = .chiken
    case 2: self = .ostrich
    case 3: self = .owl
    case 4: self = .parrot
    case 5: self = .penguin
    case 6: self = .eagle
    case 7: self = .dragon
    default: self = .chiken
    }
  }

}
