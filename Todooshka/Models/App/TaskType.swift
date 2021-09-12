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

enum TaskTypeStatus: String, Codable {
  case active = "active"
  case archived = "archived" // если у типа есть привязанные задачи
  case deleted = "deleted" // удален и можно посмотреть в спсике удаленных типов
  case hardDeleted = "hardDeleted" // полностью удален и ждет удаления в Firebase
}

class TaskType: IdentifiableType, Equatable  {
  
  //MARK: - Properties
  var identity: String
  var imageName: String?
  var imageColorHex: String?
  var text: String = ""
  var orderNumber: Int
  
  //MARK: - GET Properties
  var image: UIImage? {
    guard let imageName = imageName else { return nil }
    return UIImage(named: imageName)?.template
  }
  
  var imageColor: UIColor? {
    guard let imageColorHex = imageColorHex else { return nil }
    return UIColor(hexString: imageColorHex)
  }
  
  //MARK: - Init
  init(UID: String, imageName: String?, imageColorHex: String?, text: String, orderNumber: Int) {
    self.identity = UID
    self.imageName = imageName
    self.imageColorHex = imageColorHex
    self.text = text
    self.orderNumber = orderNumber
  }
  
  init?(snapshot: DataSnapshot) {
    guard let snapshotDict = snapshot.value as? [String: Any] else { return nil }
    guard
      let imageName = snapshotDict["imageName"] as? String,
      let imageColorHex = snapshotDict["imageColorHex"] as? String,
      let text = snapshotDict["text"] as? String,
      let orderNumber = snapshotDict["orderNumber"] as? Int
    else { return nil }
    
    self.identity = snapshot.key
    self.imageName = imageName
    self.imageColorHex = imageColorHex
    self.text = text
    self.orderNumber = orderNumber
  }
  
  init?(coreDataTaskType: CoreDataTaskType) {
    guard
      let UID = coreDataTaskType.uid,
      let imageName = coreDataTaskType.imageName,
      let imageColorHex = coreDataTaskType.imageColorHex,
      let text = coreDataTaskType.text
    else { return nil}
    
    self.identity = UID
    self.imageName = imageName
    self.imageColorHex = imageColorHex
    self.text = text
    self.orderNumber = Int(coreDataTaskType.ordernumber)
  }
  
  //MARK: - Equatable
  static func == (lhs: TaskType, rhs: TaskType) -> Bool {
    return lhs.identity == rhs.identity
  }
}
