//
//  TaskCoreData+CoreDataProperties.swift
//  
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//
//

import Foundation
import CoreData

extension TaskCoreData {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskCoreData> {
    return NSFetchRequest<TaskCoreData>(entityName: "TaskCoreData")
  }
  
  @NSManaged public var uid: String
  @NSManaged public var text: String
  @NSManaged public var desc: String
  @NSManaged public var status: String
  @NSManaged public var type: String
  @NSManaged public var serialNum: Int16
  @NSManaged public var created: Date
  @NSManaged public var planned: Date?
  @NSManaged public var closed: Date?
  @NSManaged public var userUID: String
  
  convenience init(context: NSManagedObjectContext, task: Task) {
    self.init(context: context)
    self.uid = task.UID
    self.text = task.text
    self.desc = task.description
    self.status = task.status.rawValue
    self.type = task.typeUID
    self.serialNum = Int16(task.serialNum)
    self.created = task.created
    self.planned = task.planned
    self.closed = task.closed
    self.userUID = ""
  }
  
  func loadFromTask(task: Task) {
    self.uid = task.UID
    self.text = task.text
    self.desc = task.description
    self.status = task.status.rawValue
    self.type = task.typeUID
    self.serialNum = Int16(task.serialNum)
    self.created = task.created
    self.planned = task.planned
    self.closed = task.closed
    self.userUID = ""
  }
}
