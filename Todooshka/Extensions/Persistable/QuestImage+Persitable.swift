//
//  QuestImage+Persitable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 12.05.2023.
//

import CoreData
import UIKit

extension QuestImage: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    "QuestImage"
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
      let questUUID = entity.value(forKey: "questUUID") as? UUID,
      let imageData = entity.value(forKey: "imageData") as? Data,
      let image = UIImage(data: imageData)
    else {
      return nil
    }
    
    self.uuid = uuid
    self.questUUID = questUUID
    self.image = image
    
    self.rank = entity.value(forKey: "rank") as? Int ?? 0
  }
  
  func update(_ entity: NSManagedObject) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(questUUID, forKey: "questUUID")
    entity.setValue(image.pngData(), forKey: "imageData")
    entity.setValue(rank, forKey: "rank")
  }
  
  func save(_ entity: NSManagedObject) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}

