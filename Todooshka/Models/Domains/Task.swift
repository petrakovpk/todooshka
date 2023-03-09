//
//  Task.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 20.05.2021.
//

import CoreData
import Firebase
import RxDataSources

struct Task: IdentifiableType, Equatable {
  var identity: String { UID }
 
  let UID: String
  var text: String = "" { willSet { lastModified = Date()}}
  var description: String = "" { willSet { lastModified = Date()}}
  var status: TaskStatus { willSet { lastModified = Date()}}
  var index: Int = 0 { willSet { lastModified = Date()}}
  var created = Date() { willSet { lastModified = Date()}}
  var planned = Date().endOfDay { willSet { lastModified = Date()}}
  var completed: Date? { willSet { lastModified = Date()}}
  var kindOfTaskUID: String = KindOfTask.Standart.Simple.UID { willSet { lastModified = Date()}}
  var userUID: String? = Auth.auth().currentUser?.uid { willSet { lastModified = Date()}}
  var lastModified = Date()
  var imageUID: String?

  // MARK: - Calculated Propertie
  var secondsLeft: Double {
    max(planned.timeIntervalSince1970 - Date().startOfDay.timeIntervalSince1970, 0)
  }

  // MARK: - init
  init(UID: String, status: TaskStatus) {
    self.UID = UID
    self.status = status
  }
  
  init(UID: String, status: TaskStatus, planned: Date, completed: Date?) {
    self.UID = UID
    self.status = status
    self.planned = planned
    self.completed = completed
  }

  // MARK: - Equatable
  static func == (lhs: Task, rhs: Task) -> Bool {
    return lhs.UID == rhs.UID
    && lhs.text == rhs.text
    && lhs.description == rhs.description
    && lhs.status == rhs.status
    && lhs.kindOfTaskUID == rhs.kindOfTaskUID
    && lhs.created == rhs.created
    && lhs.completed == rhs.completed
    && lhs.planned == rhs.planned
    && lhs.index == rhs.index
    && lhs.userUID == rhs.userUID
    && lhs.lastModified == rhs.lastModified
    && lhs.imageUID == rhs.imageUID
  }
}

// MARK: - Firebase
extension Task: Firebasable {
  typealias D = DataSnapshot

  var data: [String: Any] {
    [
        "text": text,
        "desc": description,
        "status": status.rawValue,
        "kindOfTaskUID": kindOfTaskUID,
        "created": created.timeIntervalSince1970,
        "closed": completed?.timeIntervalSince1970,
        "planned": planned.timeIntervalSince1970,
        "index": index,
        "lastModified": lastModified.timeIntervalSince1970,
        "imageUID": imageUID
    ]
  }
  
  var publishData: [String: Any] {
    [
        "text": text,
        "desc": description,
        "status": status.rawValue,
        "kindOfTaskUID": kindOfTaskUID,
        "created": created.timeIntervalSince1970,
        "closed": completed?.timeIntervalSince1970,
        "planned": planned.timeIntervalSince1970,
        "index": index,
        "lastModified": lastModified.timeIntervalSince1970,
        "userUID": userUID,
        "imageUID": imageUID
    ]
  }

  init?(snapshot: D) {
    guard let dict = snapshot.value as? NSDictionary,
          let text = dict.value(forKey: "text") as? String,
          let description = dict.value(forKey: "desc") as? String,
          let statusRawValue = dict.value(forKey: "status") as? String,
          let status = TaskStatus(rawValue: statusRawValue),
          let kindOfTaskUID = dict.value(forKey: "kindOfTaskUID") as? String,
          let createdTimeInterval = dict.value(forKey: "created") as? TimeInterval,
          let index = dict.value(forKey: "index") as? Int,
          let lastModifiedTimeInterval = dict.value(forKey: "lastModified") as? TimeInterval
    else { return nil }

    self.UID = snapshot.key
    self.text = text
    self.description = description
    self.status = status
    self.kindOfTaskUID = kindOfTaskUID
    self.created = Date(timeIntervalSince1970: createdTimeInterval)
    self.index = index
    self.userUID = dict.value(forKey: "userUID") as? String
    self.lastModified = Date(timeIntervalSince1970: lastModifiedTimeInterval)
    self.imageUID = dict.value(forKey: "imageUID") as? String

    if let closedTimeInterval = dict.value(forKey: "closed") as? TimeInterval {
      self.completed = Date(timeIntervalSince1970: closedTimeInterval)
    }
    
    if let plannedTimeInterval = dict.value(forKey: "planned") as? TimeInterval {
      self.planned = Date(timeIntervalSince1970: plannedTimeInterval)
    }
  }
}

// MARK: - Persistable
extension Task: Persistable {
  typealias T = NSManagedObject

  static var entityName: String { "Task" }
  static var primaryAttributeName: String { "uid" }

  init?(entity: T) {
    guard
      let UID = entity.value(forKey: "uid") as? String,
      let created = entity.value(forKey: "created") as? Date,
      let description = entity.value(forKey: "desc") as? String,
      let index = entity.value(forKey: "index") as? Int,
      let kindOfTaskUID = entity.value(forKey: "kindOfTaskUID") as? String,
      let statusRawValue = entity.value(forKey: "statusRawValue") as? String,
      let status = TaskStatus(rawValue: statusRawValue),
      let text = entity.value(forKey: "text") as? String,
      let lastModified = entity.value(forKey: "lastModified") as? Date,
      let planned = entity.value(forKey: "planned") as? Date
    else { return nil }

    self.UID = UID
    self.created = created
    self.index = index
    self.kindOfTaskUID = kindOfTaskUID
    self.status = status
    self.text = text
    self.lastModified = lastModified
    self.completed = entity.value(forKey: "closed") as? Date
    self.description = description
    self.planned = planned
    self.userUID = entity.value(forKey: "userUID") as? String
    self.imageUID = entity.value(forKey: "imageUID") as? String
  }

  func update(_ entity: T) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(completed, forKey: "closed")
    entity.setValue(created, forKey: "created")
    entity.setValue(description, forKey: "desc")
    entity.setValue(index, forKey: "index")
    entity.setValue(kindOfTaskUID, forKey: "kindOfTaskUID")
    entity.setValue(planned, forKey: "planned")
    entity.setValue(status.rawValue, forKey: "statusRawValue")
    entity.setValue(text, forKey: "text")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(lastModified, forKey: "lastModified")
    entity.setValue(imageUID, forKey: "imageUID")
  }

  func save(_ entity: T) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
