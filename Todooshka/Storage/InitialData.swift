//
//  InitialData.swift
//  DragoDo
//
//  Created by Pavel Petakov on 16.04.2023.
//

import UIKit

struct InitialData {
  
  static let publicKinds: [PublicKind] = [
    PublicKind(
      uuid: UUID(),
      image: UIImage(named: "breakfast_qc") ?? UIImage(),
      text: "Завтраки"),
   
    PublicKind(
      uuid: UUID(),
      image: UIImage(named: "gym_qc") ?? UIImage(),
      text: "Спортзал"),
  
    PublicKind(
      uuid: UUID(),
      image: UIImage(named: "home_qc") ?? UIImage(),
      text: "Домашние дела"),
   
    PublicKind(
      uuid: UUID(),
      image: UIImage(named: "pet_qc") ?? UIImage(),
      text: "Питомцы")
  ]
  
  static let kinds: [Kind] = [
    Kind(
      uuid: UUID(),
      color: Palette.SingleColors.PurpleHeart,
      icon: .teacher,
      index: 1,
      text: "Учеба"
    ),
    
    Kind(
      uuid: UUID(),
      color: Palette.SingleColors.PurpleHeart,
      icon: .briefcase,
      index: 2,
      text: "Работа"
    ),
    
    Kind(
      uuid: UUID(),
      color: Palette.SingleColors.Jaffa,
      icon: .profile2user,
      index: 3,
      text: "Готовка"
    ),
    
    Kind(
      uuid: UUID(),
      color: Palette.SingleColors.Cerise,
      icon: .home,
      index: 4,
      text: "Домашние дела"
    ),
    
    Kind(
      uuid: UUID(),
      color: Palette.SingleColors.Amethyst,
      icon: .emojiHappy,
      index: 5,
      text: "Детишки"
    ),
    
    Kind(
      uuid: UUID(),
      color: Palette.SingleColors.Amethyst,
      icon: .lovely,
      index: 6,
      text: "Вторая половинка"
    ),
    
    Kind(
      uuid: UUID(),
      color: Palette.SingleColors.BrinkPink,
      icon: .pet,
      index: 7,
      text: "Домашнее животное"
    ),
    
    Kind(
      uuid: UUID(),
      color: Palette.SingleColors.BlushPink,
      icon: .dumbbell,
      index: 8,
      text: "Спорт"
    ),
    
    Kind(
      uuid: UUID(),
      color: Palette.SingleColors.BlushPink,
      icon: .shop,
      index: 9,
      text: "Мода"
    )
  ]
}
