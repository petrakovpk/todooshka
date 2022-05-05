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
  var icon: Icon
  var color: TypeColor
  var text: String
  var serialNum: Int
  var status: TypeStatus = .active
  var isSelected: Bool = false
  var birdUID: String?
  
  //MARK: - Identity
  var identity: String {
    return UID
  }
  
  //MARK: - Init
  init(UID: String, icon: Icon, color: TypeColor, text: String, serialNum: Int, birdUID: String) {
    self.UID = UID
    self.icon = icon
    self.color = color
    self.text = text
    self.serialNum = serialNum
    self.birdUID = birdUID
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
    self.isSelected = typeCoreData.isSelected
    self.birdUID = typeCoreData.bird
  }
  
  // MARK: - Equatable
  static func == (lhs: TaskType, rhs: TaskType) -> Bool {
    return lhs.identity == rhs.identity
    && lhs.isSelected == rhs.isSelected
    && lhs.birdUID == rhs.birdUID
  }
}


// MARK: - Static Properties
extension TaskType {
  
  struct Standart {
    
    static let Empty: TaskType = TaskType(UID: "Empty", icon: .Unlimited, color: .Corduroy, text: "Без типа", serialNum: 0, birdUID: Bird.Chiken.Simple.UID)
    
    static let Work = TaskType(UID: "Work", icon: .Briefcase, color: .PurpleHeart, text: "Работа", serialNum: 1, birdUID: Bird.Chiken.Simple.UID)
    
    static let Family = TaskType(UID: "Family", icon: .Profile2user, color: .Jaffa, text: "Семья", serialNum: 0, birdUID: Bird.Chiken.Simple.UID)
    
    static let Home = TaskType(UID: "Home", icon: .House, color: .Cerise, text: "Дом", serialNum: 0, birdUID: Bird.Chiken.Simple.UID)
    
    static let Love = TaskType(UID: "Love", icon: .Lovely, color: .Amethyst, text: "Вторая половинка", serialNum: 0, birdUID: Bird.Chiken.Simple.UID)
    
    static let Pet = TaskType(UID: "Pet", icon: .Pet, color: .BrinkPink, text: "Домашнее животное", serialNum: 0, birdUID: Bird.Chiken.Simple.UID)
    
    static let Sport = TaskType(UID: "Sport", icon: .Dumbbell, color: .BlushPink, text: "Спорт", serialNum: 0, birdUID: Bird.Chiken.Simple.UID)
  }
  
  
  
//  static let New: TaskType = TaskType(UID: UUID().uuidString, icon: .Unlimited, color: .Corduroy, text: "Новый тип", serialNum: 0, birdUID: Bird.Chiken.Simple.UID)
  
 
  
}
