//
//  PointCoreData+CoreDataProperties.swift
//  
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//
//

import Foundation
import CoreData

extension PointCoreData {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<PointCoreData> {
    return NSFetchRequest<PointCoreData>(entityName: "PointCoreData")
  }
  
  @NSManaged public var created: Date
  @NSManaged public var currency: String
  @NSManaged public var uid: String
  @NSManaged public var taskUID: String
  
  convenience init(context: NSManagedObjectContext, point: Point) {
    self.init(context: context)
    self.created = point.created
    self.uid = point.UID
    self.currency = point.currency.rawValue
    self.taskUID = point.taskUID
  }
}
