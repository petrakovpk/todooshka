//
//  TDImage.swift
//  DragoDo
//
//  Created by Pavel Petakov on 02.03.2023.
//
import CoreData
import UIKit

struct TDImage {
  let UID: String
  var data: Data
  
  var image: UIImage {
    UIImage(data: self.data) ?? UIImage()
  }
}

// MARK: Ext - Equatable
extension TDImage: Equatable {
  static func == (lhs: TDImage, rhs: TDImage) -> Bool {
    return lhs.UID == rhs.UID
    && lhs.data == rhs.data
  }
}

// MARK: Ext - Persistable
extension TDImage: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    "TDImage"
  }
  
  static var primaryAttributeName: String {
    "uid"
  }
  
  var identity: String {
    self.UID
  }
  
  init?(entity: NSManagedObject) {
    guard
      let UID = entity.value(forKey: "uid") as? String,
      let data = entity.value(forKey: "data") as? Data
    else { return nil }
    
    self.UID = UID
    self.data = data
  }
  
  func update(_ entity: NSManagedObject) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(data, forKey: "data")
  }
  
  func save(_ entity: NSManagedObject) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}


