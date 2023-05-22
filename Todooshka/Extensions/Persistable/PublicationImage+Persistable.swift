//
//  PublicationImage+Persistable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 12.05.2023.
//

import CoreData
import UIKit

extension PublicationImage: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    "PublicationImage"
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
      let publicationUUID = entity.value(forKey: "publicationUUID") as? UUID,
      let imageData = entity.value(forKey: "imageData") as? Data,
      let image = UIImage(data: imageData)
    else {
      return nil
    }
    
    self.uuid = uuid
    self.publicationUUID = publicationUUID
    self.image = image
    
  }
  
  func update(_ entity: NSManagedObject) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(publicationUUID, forKey: "publicationUUID")
    entity.setValue(image.pngData(), forKey: "imageData")
  }
  
  func save(_ entity: NSManagedObject) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}


