//
//  TaskType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 27.06.2021.
//

import Foundation
import Firebase
import UIKit
import RxDataSources

class TaskType: IdentifiableType, Equatable  {
  
  var identity: String { return self.UID }
  var UID: String
  var image: UIImage? {
    switch self.UID {
    case "family":
      return UIImage(named: "profile-2user")?.template
    case "business":
      return UIImage(named: "monitor")?.template
    case "house":
      return UIImage(named: "home")?.template
    case "love":
      return UIImage(named: "lovely")?.template
    case "work":
      return UIImage(named: "briefcase")?.template
    case "sport":
      return UIImage(named: "weight")?.template
    default:
      return UIImage(systemName: self.systemImageName)!
    }
    return nil
  }
  
  var imageColor: UIColor? {
    switch self.UID {
    case "family":
      return UIColor(named: "typeFamilyTintColor")
    case "business":
      return UIColor(named: "typeBusinessTintColor")
    case "house":
      return UIColor(named: "typeHouseTintColor")
    case "love":
      return UIColor(named: "typeLoveTintColor")
    case "work":
      return UIColor(named: "typeWorkTintColor")
    case "sport":
      return UIColor(named: "typeSportTintColor")
    default:
      return UIColor(named: "typeFamilyTintColor")
    }
    return nil
  }
  var systemImageName: String
  var text: String
  var orderNumber: Int
  
  init(UID: String, systemImageName: String, text: String, orderNumber: Int) {
    self.UID = UID
    self.systemImageName = systemImageName
    self.text = text
    self.orderNumber = orderNumber
  }
  
  init?(snapshot: DataSnapshot) {
    guard let snapshotDict = snapshot.value as? [String: Any] else { return nil }
    guard
      let systemImageName = snapshotDict["systemImageName"] as? String,
      let text = snapshotDict["text"] as? String,
      let orderNumber = snapshotDict["orderNumber"] as? Int
    else { return nil }
    self.UID = snapshot.key
    self.systemImageName = systemImageName
    self.text = text
    self.orderNumber = orderNumber
  }
  
  init?(coreDataTaskType: CoreDataTaskType) {
    
    guard
      let UID = coreDataTaskType.uid,
      let systemImageName = coreDataTaskType.systemimagename,
      let text = coreDataTaskType.text,
      let orderNumber = coreDataTaskType.ordernumber
    else { return nil}
    
    self.UID = UID
    self.systemImageName = systemImageName
    self.text = text
    self.orderNumber = Int(truncating: orderNumber)
  }
  
  static func == (lhs: TaskType, rhs: TaskType) -> Bool {
    return lhs.UID == rhs.UID
  }
}
