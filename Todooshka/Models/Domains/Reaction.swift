//
//  Reaction.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import CoreData
import Firebase

enum ReactionType: String {
  case like
  case dislike
}

struct Reaction {
  let UID: String
  let userUID: String
  let taskUID: String
  let type: ReactionType
}

extension Reaction: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    "Reaction"
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
      let userUID = entity.value(forKey: "userUID") as? String,
      let taskUID = entity.value(forKey: "taskUID") as? String,
      let typeRawValue = entity.value(forKey: "type") as? String,
      let type = ReactionType(rawValue: typeRawValue)
    else { return nil }
    
    self.UID = UID
    self.userUID = userUID
    self.taskUID = taskUID
    self.type = type
  }
  
  func update(_ entity: NSManagedObject) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(taskUID, forKey: "taskUID")
    entity.setValue(type.rawValue, forKey: "type")
  }
  
  func save(_ entity: NSManagedObject) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}

extension Reaction: Firebasable {
  typealias D = DataSnapshot
  
  var data: [String : Any] {
    [
      "uid": UID,
      "userUID": userUID,
      "taskUID": taskUID,
      "type": type.rawValue
    ]
  }
  
  init?(dataSnapshot: DataSnapshot) {
    guard let dict = dataSnapshot.value as? NSDictionary,
          let userUID = dict.value(forKey: "userUID") as? String,
          let taskUID = dict.value(forKey: "taskUID") as? String,
          let typeRawValue = dict.value(forKey: "type") as? String,
          let type = ReactionType(rawValue: typeRawValue)
    else { return nil }
    
    self.UID = dataSnapshot.key
    self.userUID = userUID
    self.taskUID = taskUID
    self.type = type
  }
  
  init?(documentSnapshot: QueryDocumentSnapshot) {
    let data = documentSnapshot.data()
    guard let userUID = data["userUID"] as? String,
          let taskUID = data["taskUID"] as? String,
          let typeRawValue = data["type"] as? String,
          let type = ReactionType(rawValue: typeRawValue)
    else { return nil }
    
    self.UID = documentSnapshot.documentID
    self.userUID = userUID
    self.taskUID = taskUID
    self.type = type
  }
}
