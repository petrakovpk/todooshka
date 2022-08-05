//
//  Style.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.04.2022.
//

enum Style: String {
  
  // Курица
  case Simple = "обычный"
  // Пингвин
  case Business = "деловой"
  // Страус
  case Student = "студент"
  // Попугай
  case Cook = "повар"
  // Орел
  case Fashion = "модный"
  // Сова
  case Kid = "ребенок"
  // Дракон
  case Sport = "спортивный"
  
  // birdN
  var birdN: Int {
    switch self {
    case .Simple: return 0
    case .Student: return 1
    case .Business: return 2
    case .Cook: return 3
    case .Fashion: return 4
    case .Sport: return 5
    case .Kid: return 6
    }
  }
}
