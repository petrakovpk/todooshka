//
//  UserExtData+Persistable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.05.2023.
//

import CoreData
import RxSwift
import RxCocoa

extension UserExtData: Persistable {
  var identity: String {
    userUID
  }
  
  typealias T = NSManagedObject

  static var entityName: String {
    return "UserExtData"
  }

  static var primaryAttributeName: String {
    return "userUID"
  }

  init?(entity: T) {
    guard
      let userUID = entity.value(forKey: "userUID") as? String
    else { return nil }

    self.userUID = userUID
    self.nickName = entity.value(forKey: "nickName") as? String
    
    if let imageData = entity.value(forKey: "imageData") as? Data, let image = UIImage(data: imageData) {
      self.image = image
    }
   
  }

  func update(_ entity: T) {
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(nickName, forKey: "nickName")
    entity.setValue(image?.pngData(), forKey: "imageData")
  }

  func save(_ entity: T) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
