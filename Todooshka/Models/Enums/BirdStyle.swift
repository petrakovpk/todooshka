//
//  Style.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.04.2022.
//

import UIKit

enum BirdStyle: String {
  case simple = "Simple"
  case business = "Business"
  case student = "Student"
  case cook = "Cook"
  case fashion = "Fashion"
  case kid = "Kid"
  case sport = "Sport"

  // index
  var index: Int {
    switch self {
    case .simple: return 0
    case .student: return 1
    case .business: return 2
    case .cook: return 3
    case .fashion: return 4
    case .sport: return 5
    case .kid: return 6
    }
  }

  // image
  var imageName: String {
    switch self {
    case .simple: return "обычный"
    case .student: return "студент"
    case .business: return "деловой"
    case .cook: return "повар"
    case .fashion: return "модный"
    case .sport: return "спортивный"
    case .kid: return "ребенок"
    }
  }

  var image: UIImage? {
    switch self {
    case .simple: return Icon.unlimited.image
    case .student: return Icon.teacher.image
    case .business: return Icon.briefcase.image
    case .cook: return Icon.profile2user.image
    case .fashion: return Icon.shop.image
    case .sport: return Icon.dumbbell.image
    case .kid: return Icon.emojiHappy.image
    }
  }

  var description: String {
    switch self {
    case .simple:
      return "Мастер на все крылышки. Берется с энтузиазмом за любую задачу, настоящий профи! Ну а кто, если не она?"
    case .student:
      return "Сессия сама себя не закроет, а наш студент со всем справится! Потихоньку, маленькими шажками, грызет гранит науки днями и ночами."
    case .business:
      return "Кто хочет стать миллионером?  Конечно же наш трудоголик! 20 % его усилий приносят целое состояние."
    case .cook:
      return "Как не порадовать близких и себя любимого? Можно блеснуть кулинарными способностями и получить звездочку Мишлен (пусть даже воображаемую)."
    case .fashion:
      return "Это вэри импотант для сегодняшней жизни добавить немножко дизайнс и фэшн сьютс для каждого из нас любого сайз энд шэйп."
    case .sport:
      return "Надо-надо подкачаться! Берем руки в ноги и бежим на тренировку. Лето уже близко."
    case .kid:
      return "Твоя крошка - это причина улыбаться каждое утро. Дарить любовь, заботу и уважение наша главная задача, ведь в его глазах ты видишь свое отражение."
    }
  }
}
