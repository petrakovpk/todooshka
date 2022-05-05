//
//  TypeCoreData+CoreDataProperties.swift
//  
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//
//

import Foundation
import CoreData

extension TypeCoreData {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<TypeCoreData> {
    return NSFetchRequest<TypeCoreData>(entityName: "TypeCoreData")
  }
  
  @NSManaged public var uid: String
  @NSManaged public var text: String
  @NSManaged public var status: String
  @NSManaged public var serialNum: Int16
  @NSManaged public var color: String
  @NSManaged public var icon: String
  @NSManaged public var isSelected: Bool
  @NSManaged public var bird: String?
  
  convenience init(context: NSManagedObjectContext, type: TaskType) {
    self.init(context: context)
    self.uid = type.UID
    self.text = type.text
    self.status = type.status.rawValue
    self.serialNum = Int16(type.serialNum)
    self.icon = type.icon.rawValue
    self.color = type.color.rawValue
    self.isSelected = type.isSelected
    self.bird = type.birdUID
  }
  
  func loadFromType(type: TaskType) {
    self.uid = type.UID
    self.text = type.text
    self.status = type.status.rawValue
    self.serialNum = Int16(type.serialNum)
    self.icon = type.icon.rawValue
    self.color = type.color.rawValue
    self.isSelected = type.isSelected
    self.bird = type.birdUID
  }
}
