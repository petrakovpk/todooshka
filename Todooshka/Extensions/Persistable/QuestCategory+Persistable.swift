//
//  QuestCategory+Persistable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.05.2023.
//

import CoreData
import UIKit

extension PublicKind: Persistable {
  typealias T = NSManagedObject

  static var entityName: String {
    return "PublicKind"
  }

  static var primaryAttributeName: String {
    return "uuid"
  }

  init?(entity: T) {
    guard
      let uuid = entity.value(forKey: "uuid") as? UUID,
      let imageData = entity.value(forKey: "imageData") as? Data,
      let image = UIImage(data: imageData),
      let text = entity.value(forKey: "text") as? String
    else { return nil }

    self.uuid = uuid
    self.image = image
    self.text = text
  }

  func update(_ entity: T) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(image.pngData(), forKey: "imageData")
    entity.setValue(text, forKey: "text")
  }

  func save(_ entity: T) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}

