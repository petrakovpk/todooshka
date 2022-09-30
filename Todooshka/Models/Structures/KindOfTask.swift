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
    static let Simple = KindOfTask(UID: "Simple", icon: .Unlimited, isStyleLocked: true, color: Palette.SingleColors.Corduroy , text: "Без типа", index: 0, style: .Simple)
    static let Student = KindOfTask(UID: "Student", icon: .Teacher, isStyleLocked: true, color: Palette.SingleColors.PurpleHeart, text: "Учеба", index: 1, style: .Student)
    static let Business = KindOfTask(UID: "Business", icon: .Briefcase, isStyleLocked: true, color: Palette.SingleColors.PurpleHeart, text: "Работа", index: 2, style: .Business)
    static let Cook = KindOfTask(UID: "Cook", icon: .Profile2user, isStyleLocked: true, color: Palette.SingleColors.Jaffa, text: "Готовка", index: 3, style: .Cook)
    static let Home = KindOfTask(UID: "Home", icon: .House, isStyleLocked: false, color: Palette.SingleColors.Cerise, text: "Домашние дела", index: 4, style: .Simple)
    static let Kid = KindOfTask(UID: "Kid", icon: .EmojiHappy, isStyleLocked: true, color: Palette.SingleColors.Amethyst, text: "Детишки", index: 5, style: .Kid)
    static let Love = KindOfTask(UID: "Love", icon: .Lovely, isStyleLocked: false, color: Palette.SingleColors.Amethyst, text: "Вторая половинка", index: 6, style: .Simple)
    static let Pet = KindOfTask(UID: "Pet", icon: .Pet, isStyleLocked: false, color: Palette.SingleColors.BrinkPink, text: "Домашнее животное", index: 7, style: .Simple)
    static let Sport = KindOfTask(UID: "Sport", icon: .Dumbbell, isStyleLocked: true, color: Palette.SingleColors.BlushPink, text: "Спорт", index: 8, style: .Sport)
    static let Fashion = KindOfTask(UID: "Fashion", icon: .Shop, isStyleLocked: true, color: Palette.SingleColors.BlushPink, text: "Быть модным", index: 9, style: .Fashion)
  }
  
  // MARK: - Identity
  var identity: String { UID }
  
  // MARK: - Properties
  var UID: String { didSet { lastModified = Date().timeIntervalSince1970 }}
  var color: UIColor { didSet { lastModified = Date().timeIntervalSince1970 }}
  var icon: Icon { didSet { lastModified = Date().timeIntervalSince1970 }}
  var index: Int { didSet { lastModified = Date().timeIntervalSince1970 }}
  var isStyleLocked: Bool = false { didSet { lastModified = Date().timeIntervalSince1970 }}
  var status: KindOfTaskStatus = .Active { didSet { lastModified = Date().timeIntervalSince1970 }}
  var style: Style = .Simple { didSet { lastModified = Date().timeIntervalSince1970 }}
  var text: String { didSet { lastModified = Date().timeIntervalSince1970 }}
  var userUID: String? = Auth.auth().currentUser?.uid { didSet { lastModified = Date().timeIntervalSince1970 }}
  
  var lastModified: Double = Date().timeIntervalSince1970

  // MARK: - Init
  init(UID: String, icon: Icon, isStyleLocked: Bool, color: UIColor?, text: String, index: Int) {
    self.UID = UID
    self.color = color ?? UIColor.systemGray
    self.icon = icon
    self.index = index
    self.isStyleLocked = isStyleLocked
    self.text = text
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
      "styleRawValue": style.rawValue,
      "text": text,
      "lastModified": lastModified
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
          let styleRawValue = dict.value(forKey: "styleRawValue") as? String,
          let style = Style(rawValue: styleRawValue),
          let text = dict.value(forKey: "text") as? String,
          let lastModified = dict.value(forKey: "lastModified") as? Double
    else { return nil }
    
    // init
    self.UID = snapshot.key
    self.color = color
    self.icon = icon
    self.index = index
    self.status = status
    self.style = style
    self.text = text
    self.lastModified = lastModified
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
    lastModified = entity.value(forKey: "lastModified") as! Double
    
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
    
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
