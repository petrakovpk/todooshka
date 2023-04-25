//
//  Theme.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import CoreData
import Differentiator
import Firebase

struct Theme: Equatable {
  var authorUID: String? = Auth.auth().currentUser?.uid 
  var description: String
  var image: UIImage?
  var name: String
  var status: ThemeStatus
  var type: ThemeType
  let uid: String
}

// MARKL - Static
extension Theme {
  static let empty = Theme(authorUID: Auth.auth().currentUser?.uid, description: "", image: nil, name: "", status: .draft, type: .empty, uid: UUID().uuidString)
}

// MARK: - IdentifiableType
extension Theme: IdentifiableType {
  var identity: String { uid }
}

// MARK: - Persistable
extension Theme: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String { "Theme" }
  static var primaryAttributeName: String { "uid" }

  init?(entity: T) {
    guard
      let uid = entity.value(forKey: "uid") as? String,
      let description = entity.value(forKey: "desc") as? String,
      let name = entity.value(forKey: "name") as? String,
      let statusRawValue = entity.value(forKey: "statusRawValue") as? String,
      let status = ThemeStatus(rawValue: statusRawValue),
      let typeRawValue = entity.value(forKey: "typeRawValue") as? String,
      let type = ThemeType(rawValue: typeRawValue)
    else { return nil }
    
    self.description = description
    self.name = name
    self.status = status
    self.type = type
    self.uid = uid
    
    if let data = entity.value(forKey: "image") as? Data, let image = UIImage(data: data) {
      self.image = image
    }
  }

  func update(_ entity: T) {
    entity.setValue(description, forKey: "desc")
    entity.setValue(name, forKey: "name")
    entity.setValue(status.rawValue, forKey: "statusRawValue")
    entity.setValue(type.rawValue, forKey: "typeRawValue")
    entity.setValue(uid, forKey: "uid")
    
    if let data = image?.pngData() {
      entity.setValue(data, forKey: "image")
    }
   
  }

  func save(_ entity: T) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
