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
    case .Penguin: return 2
    case .Ostrich: return 3
    case .Parrot: return 4
    case .Eagle: return 5
    case .Owl: return 6
    case .Dragon: return 7
    }
  }
  
  // text
  var text: String {
    switch self {
    case .Chiken: return "1-я задача, Курица"
    case .Penguin: return "2-я задача, Пингвин"
    case .Ostrich: return "3-я задача, Страус"
    case .Parrot: return "4-я задача, Попугай"
    case .Eagle: return "5-я задача, Орел"
    case .Owl: return "6-я задача, Сова"
    case .Dragon: return "7-я задача, Дракон"
    }
  }
  
  // init
  init(level: Int) {
    switch level {
    case 1: self = .Chiken
    case 2: self = .Penguin
    case 3: self = .Ostrich
    case 4: self = .Parrot
    case 5: self = .Eagle
    case 6: self = .Owl
    case 7: self = .Dragon
    default: self = .Chiken
    }
  }

  
}
