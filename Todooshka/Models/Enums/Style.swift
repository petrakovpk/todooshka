//
//  Style.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.04.2022.
//

enum Style: String {
  
  case Simple = "Empty"
  case Business = "Business"
  case Student = "Student"
  case Cook = "Cook"
  case Fashion = "Fashion"
  case Kid = "Kid"
  case Sport = "Sport"
  
  // index
  var index: Int {
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
  
  // image
  var imageName: String {
    switch self {
    case .Simple: return "обычный"
    case .Student: return "студент"
    case .Business: return "деловой"
    case .Cook: return "повар"
    case .Fashion: return "модный"
    case .Sport: return "спортивный"
    case .Kid: return "ребенок"
    }
  }
}
