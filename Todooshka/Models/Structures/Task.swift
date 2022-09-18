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
  var UID: String
  
  var text: String
  var description: String?
  
  var status: TaskStatus
  var index: Int = 0
  
  var created: Date
  var planned: Date?
  var closed: Date?
  
  // link properties
  var kindOfTaskUID: String = KindOfTask.Standart.Empty.UID
  
  //MARK: - Calculated Properties
  var identity: String { return self.UID }
  
  var is24hoursPassed: Bool {
    return created.timeIntervalSince1970 <= Date().timeIntervalSince1970 - 24 * 60 * 60
  }
  
  var secondsLeft: Double {
    return max(24 * 60 * 60 + created.timeIntervalSince1970 - Date().timeIntervalSince1970, 0)
  }
  
  var timeLeftText: String {
    let formatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH'h' mm'm' ss's'"
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      return formatter
    }()
    
    return formatter.string(from: Date(timeIntervalSince1970: secondsLeft))
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
  
  init(UID: String, text: String, description: String?, kindOfTask: KindOfTask, status: TaskStatus, created: Date, closed: Date?) {
    self.UID = UID
    self.text = text
    self.description = description
    self.status = status
    self.created = created
    self.kindOfTaskUID = kindOfTask.UID
    self.closed = closed
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
  }
  
  // MARK: - Helpers
 // func type(withTypeService service: HasTypesService) -> KindOfTask? {
    //service.typesService.types.value.first(where: { $0.UID == self.typeUID })
//  }
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
      "index": index
    ]
  }
  
  init?(snapshot: D) {
    
    // check
    guard let dict = snapshot.value as? NSDictionary,
          let text = dict.value(forKey: "text") as? String,
          let statusRawValue = dict.value(forKey: "status") as? String,
          let status = TaskStatus(rawValue: statusRawValue),
          let kindOfTaskUID = dict.value(forKey: "kindOfTaskUID") as? String,
          let created = dict.value(forKey: "created") as? TimeInterval,
          let index = dict.value(forKey: "index") as? Int
    else { return nil }
    
    // init
    self.UID = snapshot.key
    self.text = text
    self.description = dict.value(forKey: "desc") as? String
    self.status = status
    self.kindOfTaskUID = kindOfTaskUID
    self.created = Date(timeIntervalSince1970: created)
    self.index = index
    
    if let closed = dict.value(forKey: "closed") as? TimeInterval {
      self.closed = Date(timeIntervalSince1970: closed)
    }
    
    if let planned = dict.value(forKey: "planned") as? TimeInterval {
      self.planned = Date(timeIntervalSince1970: planned)
    }
  }
}

// MARK: - Persistable
extension Task: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    return "Task"
  }
  
  static var primaryAttributeName: String {
    return "uid"
  }
  
  init(entity: T) {
    UID = entity.value(forKey: "uid") as! String
    text = entity.value(forKey: "text") as! String
    description = entity.value(forKey: "desc") as? String
    status = TaskStatus(rawValue: entity.value(forKey: "status") as! String) ?? TaskStatus.InProgress
    kindOfTaskUID = entity.value(forKey: "kindOfTaskUID") as! String
    created = entity.value(forKey: "created") as! Date
    closed = entity.value(forKey: "closed") as? Date
    planned = entity.value(forKey: "planned") as? Date
    index = entity.value(forKey: "index") as! Int
  }
  
  func update(_ entity: T) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(text, forKey: "text")
    entity.setValue(description, forKey: "desc")
    entity.setValue(status.rawValue, forKey: "status")
    entity.setValue(kindOfTaskUID, forKey: "kindOfTaskUID")
    entity.setValue(created, forKey: "created")
    entity.setValue(closed, forKey: "closed")
    entity.setValue(planned, forKey: "planned")
    entity.setValue(index, forKey: "index")
    
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
