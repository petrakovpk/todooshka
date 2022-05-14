//
//  BirdStyle.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.04.2022.
//

enum BirdStyle: String {
  
  // Курица
  case Simple = "Simple"
  // Пингвин
  case Business = "Business"
  // Страус
  case Student = "Student"
  // Попугай
  case Cook = "Cook"
  // Орел
  case Fashion = "Fashion"
  // Сова
  case Kid = "Kid"
  // Дракон
  case Sport = "Sport"
  
  // index
  var index: Int {
    switch self {
    case .Simple:
      return 0
    case .Student:
      return 1
    case .Business:
      return 2
    case .Cook:
      return 3
    case .Fashion:
      return 4
    case .Sport:
      return 5
    case .Kid:
      return 6
    }
  }
  
  var stringForImage: String {
    switch self {
    case .Simple:
      return "обычный"
    case .Student:
      return "студент"
    case .Business:
      return "деловой"
    case .Cook:
      return "повар"
    case .Fashion:
      return "модный"
    case .Sport:
      return "спортивный"
    case .Kid:
      return "ребенок"
    }
  }
}
