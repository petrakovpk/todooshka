//
//  Style.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.04.2022.
//

import UIKit

enum Style: String {
  
  case Simple = "Simple"
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
  
  var image: UIImage? {
    switch self {
    case .Simple: return Icon.Unlimited.image
    case .Student: return Icon.Teacher.image
    case .Business: return Icon.Briefcase.image
    case .Cook: return Icon.Profile2user.image
    case .Fashion: return Icon.Shop.image
    case .Sport: return Icon.Dumbbell.image
    case .Kid: return Icon.EmojiHappy.image
    }
  }
}
