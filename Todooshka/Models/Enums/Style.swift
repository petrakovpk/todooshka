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
  
  var description: String {
    switch self {
    case .Simple: return "Мастер на все крылышки. Берется с энтузиазмом за любую задачу, настоящий профи! Ну а кто, если не она?"
    case .Student: return "Сессия сама себя не закроет, а наш студент со всем справится! Потихоньку, маленькими шажками, грызет гранит науки днями и ночами."
    case .Business: return "Кто хочет стать миллионером?  Конечно же наш трудоголик! 20 % его усилий приносят целое состояние."
    case .Cook: return "Как не порадовать близких и себя любимого? Можно блеснуть кулинарными способностями и получить звездочку Мишлен (пусть даже воображаемую)."
    case .Fashion: return "Это вэри импотант для сегодняшней жизни добавить немножко дизайнс и фэшн сьютс для каждого из нас любого сайз энд шэйп."
    case .Sport: return "Надо-надо подкачаться! Берем руки в ноги и бежим на тренировку. Лето уже близко."
    case .Kid: return "Твоя крошка - это причина улыбаться каждое утро. Дарить любовь, заботу и уважение наша главная задача, ведь в его глазах ты видишь свое отражение."
    }
  }
}
