//
//  TaskType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 27.06.2021.
//

import UIKit
import RxDataSources

struct TaskType: IdentifiableType, Equatable  {

  // MARK: - Properties
  var UID: String
  var text: String
  var serialNum: Int
  
  var status: TypeStatus = .active
  
  var icon: Icon
  var color: TypeColor

  // MARK: - Identity
  var identity: String {
    return UID
  }
  
  // MARK: - Init
  init(UID: String, icon: Icon, color: TypeColor, text: String, serialNum: Int) {
    self.UID = UID
    self.icon = icon
    self.color = color
    self.text = text
    self.serialNum = serialNum
  }
  
  init?(typeCoreData: TypeCoreData) {
    guard
      let status = TypeStatus(rawValue: typeCoreData.status),
      let icon = Icon(rawValue: typeCoreData.icon),
      let color = TypeColor(rawValue: typeCoreData.color)
    else { return nil }
    
    self.UID = typeCoreData.uid
    self.icon = icon
    self.color = color
    self.text = typeCoreData.text
    self.serialNum = Int(typeCoreData.serialNum)
    self.status = status
  }
  
  // MARK: - Equatable
  static func == (lhs: TaskType, rhs: TaskType) -> Bool {
    return lhs.identity == rhs.identity
  }
}

// MARK: - Static Properties
extension TaskType {
  struct Standart {
    static let Empty: TaskType = TaskType(UID: "Empty", icon: .Unlimited, color: .Corduroy, text: "Без типа", serialNum: 0)
    static let Student = TaskType(UID: "Student", icon: .Teacher, color: .PurpleHeart, text: "Учеба", serialNum: 1)
    static let Business = TaskType(UID: "Business", icon: .Briefcase, color: .PurpleHeart, text: "Работа", serialNum: 2)
    static let Cook = TaskType(UID: "Cook", icon: .Profile2user, color: .Jaffa, text: "Готовка", serialNum: 3)
    static let Home = TaskType(UID: "Home", icon: .House, color: .Cerise, text: "Домашние дела", serialNum: 4)
    static let Kid = TaskType(UID: "Kid", icon: .EmojiHappy, color: .Amethyst, text: "Детишки", serialNum: 5)
    static let Love = TaskType(UID: "Love", icon: .Lovely, color: .Amethyst, text: "Вторая половинка", serialNum: 6)
    static let Pet = TaskType(UID: "Pet", icon: .Pet, color: .BrinkPink, text: "Домашнее животное", serialNum: 7)
    static let Sport = TaskType(UID: "Sport", icon: .Dumbbell, color: .BlushPink, text: "Спорт", serialNum: 8)
    static let Fashion = TaskType(UID: "Fashion", icon: .Shop, color: .BlushPink, text: "Быть модным", serialNum: 9)
  }
}
