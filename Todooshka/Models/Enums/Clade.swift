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
  
  // eggN
  var eggN: Int {
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
  
  var birdN: Int {
    eggN
  }
  
  // init
  init?(eggN: Int) {
    switch eggN {
    case 1: self = .Chiken
    case 2: self = .Penguin
    case 3: self = .Ostrich
    case 4: self = .Parrot
    case 5: self = .Eagle
    case 6: self = .Owl
    case 7: self = .Dragon
    default: return nil
    }
  }
  
  // init
  init?(birdN: Int) {
    switch birdN {
    case 1: self = .Chiken
    case 2: self = .Penguin
    case 3: self = .Ostrich
    case 4: self = .Parrot
    case 5: self = .Eagle
    case 6: self = .Owl
    case 7: self = .Dragon
    default: return nil
    }
  }
  
}
