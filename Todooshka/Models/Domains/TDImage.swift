//
//  TDImage.swift
//  DragoDo
//
//  Created by Pavel Petakov on 02.03.2023.
//
import CoreData
import UIKit

struct TDImage {
  let uuid: UUID
  var data: Data
  
  var image: UIImage {
    UIImage(data: self.data) ?? UIImage()
  }
}

// MARK: Ext - Equatable
extension TDImage: Equatable {
  static func == (lhs: TDImage, rhs: TDImage) -> Bool {
    return lhs.uuid == rhs.uuid
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
    "uuid"
  }
  
  var identity: String {
    self.uuid.uuidString
  }
  
  init?(entity: NSManagedObject) {
    guard
      let uuid = entity.value(forKey: "uuid") as? UUID,
      let data = entity.value(forKey: "data") as? Data
    else { return nil }
    
    self.uuid = uuid
    self.data = data
  }
  
  func update(_ entity: NSManagedObject) {
    entity.setValue(uuid, forKey: "uuid")
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


