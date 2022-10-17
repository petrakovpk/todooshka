//
//  Clade.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import UIKit

enum Clade: String {
  
  // Курица
  case Chiken = "курица"
  // Пингвин
  case Penguin = "пингвин"
  // Страус
  case Ostrich = "страус"
  // Попугай
  case Parrot = "попугай"
  // Орел
  case Eagle = "орел"
  // Сова
  case Owl = "сова"
  // Дракон
  case Dragon = "дракон"
  
  // level
  var level: Int {
    switch self {
    case .Chiken: return 1
    case .Ostrich: return 2
    case .Owl: return 3
    case .Parrot: return 4
    case .Penguin: return 5
    case .Eagle: return 6
    case .Dragon: return 7
    }
  }
  
  var gender: Gender {
    switch self {
    case .Chiken, .Owl:
      return .Female
    case .Dragon, .Eagle, .Ostrich, .Parrot, .Penguin:
      return .Male
    }
  }
  
  // text
  var text: String {
    switch self {
    case .Chiken: return "Ряба"
    case .Ostrich: return "Страус"
    case .Owl: return "Сова"
    case .Parrot: return "Попугай"
    case .Penguin: return "Пингвин"
    case .Eagle: return "Орел"
    case .Dragon: return "Дракон"
    }
  }
  
  // init
  init(level: Int) {
    switch level {
    case 1: self = .Chiken
    case 2: self = .Ostrich
    case 3: self = .Owl
    case 4: self = .Parrot
    case 5: self = .Penguin
    case 6: self = .Eagle
    case 7: self = .Dragon
    default: self = .Chiken
    }
  }

  
}
