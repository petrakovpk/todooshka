//
//  CoreDataTask+CoreDataProperties.swift
//  
//
//  Created by Петраков Павел Константинович on 16.07.2021.
//
//

import Foundation
import CoreData


extension CoreDataTask {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataTask> {
    return NSFetchRequest<CoreDataTask>(entityName: "CoreDataTask")
  }
  
  @NSManaged public var text: String?
  @NSManaged public var uid: String?
  @NSManaged public var closedTimeIntervalSince1970: NSNumber?
  @NSManaged public var createdTimeIntervalSince1970: NSNumber?
  @NSManaged public var lastmodifiedtimeintervalsince1970: NSNumber?
  @NSManaged public var status: String?
  @NSManaged public var type: String?
  @NSManaged public var longText: String?
  @NSManaged public var userUID: String?
  @NSManaged public var orderNumber: NSNumber?
}

