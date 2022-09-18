//
//  KindOfTask.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 27.06.2021.
//

import CoreData
import Firebase
import RxDataSources
import UIKit

struct KindOfTask: IdentifiableType, Equatable  {

  // MARK: - Staic
  struct Standart {
    static let Empty = KindOfTask(UID: "Empty", icon: .Unlimited, color: Palette.SingleColors.Corduroy , text: "Без типа", index: 0)
    static let Student = KindOfTask(UID: "Student", icon: .Teacher, color: Palette.SingleColors.PurpleHeart, text: "Учеба", index: 1)
    static let Business = KindOfTask(UID: "Business", icon: .Briefcase, color: Palette.SingleColors.PurpleHeart, text: "Работа", index: 2)
    static let Cook = KindOfTask(UID: "Cook", icon: .Profile2user, color: Palette.SingleColors.Jaffa, text: "Готовка", index: 3)
    static let Home = KindOfTask(UID: "Home", icon: .House, color: Palette.SingleColors.Cerise, text: "Домашние дела", index: 4)
    static let Kid = KindOfTask(UID: "Kid", icon: .EmojiHappy, color: Palette.SingleColors.Amethyst, text: "Детишки", index: 5)
    static let Love = KindOfTask(UID: "Love", icon: .Lovely, color: Palette.SingleColors.Amethyst, text: "Вторая половинка", index: 6)
    static let Pet = KindOfTask(UID: "Pet", icon: .Pet, color: Palette.SingleColors.BrinkPink, text: "Домашнее животное", index: 7)
    static let Sport = KindOfTask(UID: "Sport", icon: .Dumbbell, color: Palette.SingleColors.BlushPink, text: "Спорт", index: 8)
    static let Fashion = KindOfTask(UID: "Fashion", icon: .Shop, color: Palette.SingleColors.BlushPink, text: "Быть модным", index: 9)
  }
  
  // MARK: - Properties
  var UID: String
  var color: UIColor
  var icon: Icon
  var index: Int
  var status: KindOfTaskStatus = .active
  var text: String

  // MARK: - Identity
  var identity: String {
    return UID
  }
  
  // MARK: - Init
  init(UID: String, icon: Icon, color: UIColor?, text: String, index: Int) {
    self.UID = UID
    self.color = color ?? UIColor.systemGray
    self.icon = icon
    self.index = index
    self.text = text
  }
  
  // MARK: - Equatable
  static func == (lhs: KindOfTask, rhs: KindOfTask) -> Bool {
    lhs.UID == rhs.UID &&
    lhs.icon == rhs.icon &&
    lhs.color == rhs.color &&
    lhs.text == rhs.text &&
    lhs.index == rhs.index
  }
}

// MARK: - Firebase
extension KindOfTask {
  typealias D = DataSnapshot
  
  var data: [AnyHashable: Any] {
    [
      "uid": UID,
      "colorHexString": color.hexString,
      "iconRawValue": icon.rawValue,
      "index": index,
      "statusRawValue": status.rawValue,
      "text": text
    ]
  }
  
  init?(snapshot: D) {
    
    // check
    guard let dict = snapshot.value as? NSDictionary,
          let colorHexString = dict.value(forKey: "colorHexString") as? String,
          let color = UIColor(hexString: colorHexString),
          let iconRawValue = dict.value(forKey: "iconRawValue") as? String,
          let icon = Icon(rawValue: iconRawValue),
          let index = dict.value(forKey: "index") as? Int,
          let statusRawValue = dict.value(forKey: "statusRawValue") as? String,
          let status = KindOfTaskStatus(rawValue: statusRawValue),
          let text = dict.value(forKey: "text") as? String
    else { return nil }
    
    // init
    self.UID = snapshot.key
    self.color = color
    self.icon = icon
    self.index = index
    self.status = status
    self.text = text
  }
}

// MARK: - Persistable
extension KindOfTask: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    return "KindOfTask"
  }
  
  static var primaryAttributeName: String {
    return "uid"
  }
  
  init(entity: T) {
    UID = entity.value(forKey: "uid") as! String
    index = entity.value(forKey: "index") as! Int
    text = entity.value(forKey: "text") as! String
    
    // color
    if let colorHexString = entity.value(forKey: "colorHexString") as? String, let color = UIColor(hexString: colorHexString) {
      self.color = color
    } else {
      self.color = UIColor.systemGray
    }
    
    // icon
    if let iconRawValue = entity.value(forKey: "iconRawValue") as? String, let icon = Icon(rawValue: iconRawValue) {
      self.icon = icon
    } else {
      self.icon = .Unlimited
    }
    
    // status
    if let statusRawValue = entity.value(forKey: "statusRawValue") as? String, let status = KindOfTaskStatus(rawValue: statusRawValue) {
      self.status = status
    } else {
      self.status = .active
    }
  }
  
  func update(_ entity: T) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(color.hexString, forKey: "colorHexString")
    entity.setValue(icon.rawValue, forKey: "iconRawValue")
    entity.setValue(index, forKey: "index")
    entity.setValue(status.rawValue, forKey: "statusRawValue")
    entity.setValue(text, forKey: "text")
    
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
