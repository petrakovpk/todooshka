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
    static let Simple = KindOfTask(UID: "Simple", icon: .Unlimited, isStyleLocked: true, color: Palette.SingleColors.Corduroy , text: "Без типа", index: 0, style: .Simple, lastModified: Date(timeIntervalSince1970: 0))
    static let Student = KindOfTask(UID: "Student", icon: .Teacher, isStyleLocked: true, color: Palette.SingleColors.PurpleHeart, text: "Учеба", index: 1, style: .Student, lastModified: Date(timeIntervalSince1970: 0))
    static let Business = KindOfTask(UID: "Business", icon: .Briefcase, isStyleLocked: true, color: Palette.SingleColors.PurpleHeart, text: "Работа", index: 2, style: .Business, lastModified: Date(timeIntervalSince1970: 0))
    static let Cook = KindOfTask(UID: "Cook", icon: .Profile2user, isStyleLocked: true, color: Palette.SingleColors.Jaffa, text: "Готовка", index: 3, style: .Cook, lastModified: Date(timeIntervalSince1970: 0))
    static let Home = KindOfTask(UID: "Home", icon: .House, isStyleLocked: false, color: Palette.SingleColors.Cerise, text: "Домашние дела", index: 4, style: .Simple, lastModified: Date(timeIntervalSince1970: 0))
    static let Kid = KindOfTask(UID: "Kid", icon: .EmojiHappy, isStyleLocked: true, color: Palette.SingleColors.Amethyst, text: "Детишки", index: 5, style: .Kid, lastModified: Date(timeIntervalSince1970: 0))
    static let Love = KindOfTask(UID: "Love", icon: .Lovely, isStyleLocked: false, color: Palette.SingleColors.Amethyst, text: "Вторая половинка", index: 6, style: .Simple, lastModified: Date(timeIntervalSince1970: 0))
    static let Pet = KindOfTask(UID: "Pet", icon: .Pet, isStyleLocked: false, color: Palette.SingleColors.BrinkPink, text: "Домашнее животное", index: 7, style: .Simple, lastModified: Date(timeIntervalSince1970: 0))
    static let Sport = KindOfTask(UID: "Sport", icon: .Dumbbell, isStyleLocked: true, color: Palette.SingleColors.BlushPink, text: "Спорт", index: 8, style: .Sport, lastModified: Date(timeIntervalSince1970: 0))
    static let Fashion = KindOfTask(UID: "Fashion", icon: .Shop, isStyleLocked: true, color: Palette.SingleColors.BlushPink, text: "Быть модным", index: 9, style: .Fashion, lastModified: Date(timeIntervalSince1970: 0))
  }
  
  // MARK: - Identity
  var identity: String { UID }
  
  // MARK: - Properties
  var UID: String { willSet { lastModified = Date()}}
  var color: UIColor { willSet { lastModified = Date()}}
  var icon: Icon { willSet { lastModified = Date()}}
  var index: Int { willSet { lastModified = Date()}}
  var isStyleLocked: Bool = false { willSet { lastModified = Date()}}
  var status: KindOfTaskStatus = .Active { willSet { lastModified = Date()}}
  var style: Style = .Simple { willSet { lastModified = Date()}}
  var text: String { willSet { lastModified = Date()}}
  var userUID: String? = nil
  
  var lastModified: Date = Date()

  // MARK: - Init
  init(UID: String, icon: Icon, isStyleLocked: Bool, color: UIColor?, text: String, index: Int) {
    self.UID = UID
    self.color = color ?? UIColor.systemGray
    self.icon = icon
    self.index = index
    self.isStyleLocked = isStyleLocked
    self.text = text
  }
  
  init(UID: String, icon: Icon, isStyleLocked: Bool, color: UIColor?, text: String, index: Int, userUID: String?) {
    self.UID = UID
    self.color = color ?? UIColor.systemGray
    self.icon = icon
    self.index = index
    self.isStyleLocked = isStyleLocked
    self.text = text
    self.userUID = userUID
  }
  
  init(UID: String, icon: Icon, isStyleLocked: Bool, color: UIColor?, text: String, index: Int, style: Style) {
    self.UID = UID
    self.color = color ?? UIColor.systemGray
    self.icon = icon
    self.index = index
    self.isStyleLocked = isStyleLocked
    self.text = text
    self.style = style
  }
  
  init(UID: String, icon: Icon, isStyleLocked: Bool, color: UIColor?, text: String, index: Int, style: Style, lastModified: Date) {
    self.UID = UID
    self.color = color ?? UIColor.systemGray
    self.icon = icon
    self.index = index
    self.isStyleLocked = isStyleLocked
    self.text = text
    self.style = style
    self.lastModified = lastModified
  }
  
  // MARK: - Equatable
  static func == (lhs: KindOfTask, rhs: KindOfTask) -> Bool {
    lhs.UID == rhs.UID
    && lhs.icon == rhs.icon
    && lhs.color == rhs.color
    && lhs.text == rhs.text
    && lhs.index == rhs.index
    && lhs.style == rhs.style
    && lhs.status == rhs.status
    && lhs.userUID == rhs.userUID
    && lhs.lastModified == rhs.lastModified
    && lhs.isStyleLocked == rhs.isStyleLocked
  }
}

// MARK: - Firebase
extension KindOfTask {
  typealias D = DataSnapshot
  
  var data: [AnyHashable: Any] {
    [
      "colorHexString": color.hexString,
      "iconRawValue": icon.rawValue,
      "index": index,
      "isStyleLocked": isStyleLocked,
      "statusRawValue": status.rawValue,
      "styleRawValue": style.rawValue,
      "text": text,
      "lastModified": lastModified.timeIntervalSince1970
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
          let isStyleLocked = dict.value(forKey: "isStyleLocked") as? Bool,
          let statusRawValue = dict.value(forKey: "statusRawValue") as? String,
          let status = KindOfTaskStatus(rawValue: statusRawValue),
          let styleRawValue = dict.value(forKey: "styleRawValue") as? String,
          let style = Style(rawValue: styleRawValue),
          let text = dict.value(forKey: "text") as? String,
          let lastModifiedTimeInterval = dict.value(forKey: "lastModified") as? TimeInterval
    else { return nil }
    
    // init
    self.UID = snapshot.key
    self.color = color
    self.icon = icon
    self.index = index
    self.status = status
    self.style = style
    self.text = text
    self.lastModified = Date(timeIntervalSince1970: lastModifiedTimeInterval)
    self.isStyleLocked = isStyleLocked
    self.userUID = Auth.auth().currentUser?.uid
  }
}

// MARK: - Persistable
extension KindOfTask: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String { "KindOfTask" }
  
  static var primaryAttributeName: String { "uid" }
  
  init(entity: T) {
    UID = entity.value(forKey: "uid") as! String
    index = entity.value(forKey: "index") as! Int
    isStyleLocked = entity.value(forKey: "isStyleLocked") as! Bool
    text = entity.value(forKey: "text") as! String
    userUID = entity.value(forKey: "userUID") as? String
    lastModified = entity.value(forKey: "lastModified") as! Date
    
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
      self.status = .Active
    }
    
    // style
    if let styleRawValue = entity.value(forKey: "styleRawValue") as? String, let style = Style(rawValue: styleRawValue) {
      self.style = style
    } else {
      self.style = .Simple
    }
  }
  
  func update(_ entity: T) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(color.hexString, forKey: "colorHexString")
    entity.setValue(icon.rawValue, forKey: "iconRawValue")
    entity.setValue(index, forKey: "index")
    entity.setValue(isStyleLocked, forKey: "isStyleLocked")
    entity.setValue(status.rawValue, forKey: "statusRawValue")
    entity.setValue(style.rawValue, forKey: "styleRawValue")
    entity.setValue(text, forKey: "text")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(lastModified, forKey: "lastModified")
  }
  
  func save(_ entity: T) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
