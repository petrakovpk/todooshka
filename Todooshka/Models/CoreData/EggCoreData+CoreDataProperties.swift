//
//  CDEgg+CoreDataProperties.swift
//  
//
//  Created by Петраков Павел Константинович on 25.03.2022.
//
//

import Foundation
import CoreData

extension EggCoreData {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<EggCoreData> {
    return NSFetchRequest<EggCoreData>(entityName: "EggCoreData")
  }
  
  @NSManaged public var uid: String
  @NSManaged public var created: Date
  @NSManaged public var type: String
  @NSManaged public var taskUID: String
  @NSManaged public var position: Int16
  
  // MARK: - Init
  convenience init(context: NSManagedObjectContext, egg: Egg) {
    self.init(context: context)
    self.uid = egg.UID
    self.created = egg.created
    self.type = egg.type.rawValue
    self.taskUID = egg.taskUID
    self.position = Int16(egg.position)
  }
  
  func loadFromEgg(egg: Egg) {
    self.uid = egg.UID
    self.created = egg.created
    self.type = egg.type.rawValue
    self.taskUID = egg.taskUID
    self.position = Int16(egg.position)
  }
}
