//
//  BirdClade.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import UIKit

enum BirdClade: String {
  
  // Курица
  case Chiken = "Chiken"
  // Пингвин
  case Penguin = "Penguin"
  // Страус
  case Ostrich = "Ostrich"
  // Попугай
  case Parrot = "Parrot"
  // Орел
  case Eagle = "Eagle"
  // Сова
  case Owl = "Owl"
  // Дракон
  case Dragon = "Dragon"
  
  // index
  var index: Int {
    switch self {
    case .Chiken:
      return 0
    case .Penguin:
      return 1
    case .Ostrich:
      return 2
    case .Parrot:
      return 3
    case .Eagle:
      return 4
    case .Owl:
      return 5
    case .Dragon:
      return 6
    }
  }
  
  // imageName
  var imageName: String {
    switch self {
    case .Chiken:
      return "курица"
    case .Penguin:
      return "пингвин"
    case .Ostrich:
      return "страус"
    case .Parrot:
      return "попугай"
    case .Eagle:
      return "орел"
    case .Owl:
      return "сова"
    case .Dragon:
      return "дракон"
    }
  }
  
  // image
  var image: UIImage? {
    switch self {
    case .Chiken:
      return UIImage(named: "яйцо_курицы")
    case .Penguin:
      return UIImage(named: "яйцо_пингвина")
    case .Ostrich:
      return UIImage(named: "яйцо_страуса")
    case .Parrot:
      return UIImage(named: "яйцо_попугая")
    case .Eagle:
      return UIImage(named: "яйцо_орла")
    case .Owl:
      return UIImage(named: "яйцо_совы")
    case .Dragon:
      return UIImage(named: "яйцо_дракона")
    }
  }
}
