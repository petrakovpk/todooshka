//
//  Task.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 20.05.2021.
//

import RxDataSources
import Firebase
import CoreData

enum TaskStatus: String, Codable {
  case new = "new"
  case created = "created"
  case completed = "completed"
  case deleted = "deleted"
  case idea = "idea"
  case hardDeleted = "hardDeleted"
}

class Task: IdentifiableType, Equatable {
  
  //MARK: - Main Properites
  var UID: String
  var text: String
  var description: String?
  var typeUID: String
  var status: TaskStatus
  var orderNumber: Int = 0 
  
  var createdTimeIntervalSince1970: TimeInterval
  var closedTimeIntervalSince1970: TimeInterval?
  var lastUpdateDateTime: TimeInterval
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var managedContext: NSManagedObjectContext {
    return self.appDelegate.persistentContainer.viewContext
  }
  
  //MARK: - Calculated Properties
  var identity: String { return self.UID }
  var createdDate: Date {
    return Date.init(timeIntervalSince1970: createdTimeIntervalSince1970) }
  var closedDate: Date? {
    guard let closedTimeIntervalSince1970 = self.closedTimeIntervalSince1970 else { return nil }
    return Date.init(timeIntervalSince1970: closedTimeIntervalSince1970)
  }
  
  var isCurrent: Bool {
    return status == .created && createdTimeIntervalSince1970 > (Date().timeIntervalSince1970 - 24 * 60 * 60)
  }
  
  var isOverdued: Bool {
    return status == .created && createdTimeIntervalSince1970 <= (Date().timeIntervalSince1970 - 24 * 60 * 60)
  }
  
  var type: TaskType? {
    let fetchRequest = NSFetchRequest<CoreDataTaskType>(entityName: "CoreDataTaskType")
    fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray:["uid", typeUID])
    
    do {
      if let coreDataTaskType = try managedContext.fetch(fetchRequest).first {
        return TaskType(coreDataTaskType: coreDataTaskType)
      }
    }
    catch {
      print(error.localizedDescription)
    }
    return nil
  }
  
  //MARK: - init
  init(UID: String, text: String, description: String?, typeUID: String, status: TaskStatus, createdTimeIntervalSince1970: TimeInterval) {
    self.UID = UID
    self.text = text
    self.description = description
    self.typeUID = typeUID
    self.status = status
    self.createdTimeIntervalSince1970 = createdTimeIntervalSince1970
    self.lastUpdateDateTime = Date().timeIntervalSince1970
  }
  
  init?(snapshot: DataSnapshot) {
    guard let snapshotDict = snapshot.value as? [String: Any] else { return nil }
    guard
      let typeUID = snapshotDict["type"] as? String,
      let text = snapshotDict["text"] as? String,
      let description = snapshotDict["description"] as? String,
      let statusString = snapshotDict["status"] as? String,
      let createdTimeIntervalSince1970 = snapshotDict["createdTimeIntervalSince1970"] as? TimeInterval
    else { return nil }
    
    guard let status = TaskStatus(rawValue: statusString) else { return nil }
    
    self.UID = snapshot.key
    self.typeUID = typeUID
    self.text = text
    self.description = description
    self.status = status
    self.createdTimeIntervalSince1970 = createdTimeIntervalSince1970
    self.closedTimeIntervalSince1970 = snapshotDict["closedTimeIntervalSince1970"] as? TimeInterval
    self.lastUpdateDateTime = snapshotDict["lastModifiedTimeIntervalSince1970"] as? TimeInterval ?? Date().timeIntervalSince1970
  }
  
  init?(coreDataTask: CoreDataTask) {
    guard
      let UID = coreDataTask.uid,
      let typeUID = coreDataTask.type,
      let text = coreDataTask.text,
      let statusString = coreDataTask.status,
      let createdTimeIntervalSince1970 = coreDataTask.createdTimeIntervalSince1970 as? TimeInterval,
      let description = coreDataTask.longText
    else { return nil}
    
    guard let status = TaskStatus(rawValue: statusString) else { return nil }
    
    self.UID = UID
    self.text = text
    self.description = description
    self.typeUID = typeUID
    self.status = status
    self.createdTimeIntervalSince1970 = createdTimeIntervalSince1970
    self.closedTimeIntervalSince1970 = coreDataTask.closedTimeIntervalSince1970 as? TimeInterval
    self.orderNumber = coreDataTask.orderNumber as? Int ?? 10
    
    self.lastUpdateDateTime = coreDataTask.lastmodifiedtimeintervalsince1970 as? TimeInterval ?? Date().timeIntervalSince1970
  }
  
  //MARK: - Equatable
  static func == (lhs: Task, rhs: Task) -> Bool {
    return lhs.UID == rhs.UID
  }
  
}
