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

  // MARK: - Static
  static let emptyTask: Task = Task(UID: "Empty", text: "", description: "", status: .InProgress, created: Date())
  
  // MARK: - Properites
  var identity: String { UID }
  var UID: String { didSet { lastModified = Date()}}
  
  var text: String { didSet { lastModified = Date()}}
  var description: String? { didSet { lastModified = Date()}}
  
  var status: TaskStatus { didSet { lastModified = Date()}}
  var index: Int = 0 { didSet { lastModified = Date()}}
  
  var created: Date { didSet { lastModified = Date()}}
  var planned: Date? { didSet { lastModified = Date()}}
  var closed: Date? { didSet { lastModified = Date()}}
  
  var kindOfTaskUID: String = KindOfTask.Standart.Simple.UID { didSet { lastModified = Date()}}
  var userUID: String? = Auth.auth().currentUser?.uid { didSet { lastModified = Date()}}
  
  var lastModified: Date = Date()
  
  // MARK: - Calculated Propertie
  var is24hoursPassed: Bool {
    created.timeIntervalSince1970 <= Date().timeIntervalSince1970 - 24 * 60 * 60
  }
  
  var secondsLeft: Double {
    max(24 * 60 * 60 + created.timeIntervalSince1970 - Date().timeIntervalSince1970, 0)
  }
  
  let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH'h' mm'm' ss's'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()
  
  var timeLeftText: String {
    formatter.string(from: Date(timeIntervalSince1970: secondsLeft))
  }
  
  var timeLeftPercent: Double {
    status == .InProgress ? secondsLeft / (24 * 60 * 60) : 0
  }
  
  //MARK: - init
  init(UID: String, text: String, description: String?, status: TaskStatus, created: Date) {
    self.UID = UID
    self.text = text
    self.description = description
    self.status = status
    self.created = created
  }
  
  init(UID: String, text: String, description: String?, kindOfTaskUID: String, status: TaskStatus, created: Date, closed: Date?, planned: Date?) {
    self.UID = UID
    self.text = text
    self.description = description
    self.status = status
    self.created = created
    self.kindOfTaskUID = kindOfTaskUID
    self.closed = closed
    self.planned = planned
  }
  
  // MARK: - Equatable
  static func == (lhs: Task, rhs: Task) -> Bool {
    return lhs.UID == rhs.UID
    && lhs.text == rhs.text
    && lhs.description == rhs.description
    && lhs.status == rhs.status
    && lhs.kindOfTaskUID == rhs.kindOfTaskUID
    && lhs.created == rhs.created
    && lhs.closed == rhs.closed
    && lhs.planned == rhs.planned
    && lhs.index == rhs.index
    && lhs.userUID == rhs.userUID
    && lhs.lastModified == rhs.lastModified
  }
  
}

// MARK: - Firebase
extension Task {
  typealias D = DataSnapshot
  
  var data: [AnyHashable: Any] {
    [
      "text": text,
      "desc": description,
      "status": status.rawValue,
      "kindOfTaskUID": kindOfTaskUID,
      "created": created.timeIntervalSince1970 ,
      "closed": closed?.timeIntervalSince1970,
      "planned": planned?.timeIntervalSince1970,
      "index": index,
      "lastModified": lastModified.timeIntervalSince1970
    ]
  }
  
  init?(snapshot: D) {
    
    // check
    guard let dict = snapshot.value as? NSDictionary,
          let text = dict.value(forKey: "text") as? String,
          let statusRawValue = dict.value(forKey: "status") as? String,
          let status = TaskStatus(rawValue: statusRawValue),
          let kindOfTaskUID = dict.value(forKey: "kindOfTaskUID") as? String,
          let createdTimeInterval = dict.value(forKey: "created") as? TimeInterval,
          let index = dict.value(forKey: "index") as? Int,
          let lastModifiedTimeInterval = dict.value(forKey: "lastModified") as? TimeInterval
    else { return nil }
    
    // init
    self.UID = snapshot.key
    self.text = text
    self.description = dict.value(forKey: "desc") as? String
    self.status = status
    self.kindOfTaskUID = kindOfTaskUID
    self.created = Date(timeIntervalSince1970: createdTimeInterval)
    self.index = index
    self.userUID = Auth.auth().currentUser?.uid
    self.lastModified = Date(timeIntervalSince1970: lastModifiedTimeInterval)
    
    if let closedTimeInterval = dict.value(forKey: "closed") as? TimeInterval {
      self.closed = Date(timeIntervalSince1970: closedTimeInterval)
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
  
  init(entity: T) {
    UID = entity.value(forKey: "uid") as! String
    closed = entity.value(forKey: "closed") as? Date
    created = entity.value(forKey: "created") as! Date
    description = entity.value(forKey: "desc") as? String
    index = entity.value(forKey: "index") as! Int
    kindOfTaskUID = entity.value(forKey: "kindOfTaskUID") as! String
    planned = entity.value(forKey: "planned") as? Date
    status = TaskStatus(rawValue: entity.value(forKey: "statusRawValue") as! String) ?? TaskStatus.InProgress
    text = entity.value(forKey: "text") as! String
    userUID = entity.value(forKey: "userUID") as? String
    lastModified = entity.value(forKey: "lastModified") as! Date
  }
  
  func update(_ entity: T) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(closed, forKey: "closed")
    entity.setValue(created, forKey: "created")
    entity.setValue(description, forKey: "desc")
    entity.setValue(index, forKey: "index")
    entity.setValue(kindOfTaskUID, forKey: "kindOfTaskUID")
    entity.setValue(planned, forKey: "planned")
    entity.setValue(status.rawValue, forKey: "statusRawValue")
    entity.setValue(text, forKey: "text")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(lastModified, forKey: "lastModified")
    
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
