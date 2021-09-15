//
//  CoreDataTaskType+CoreDataProperties.swift
//  
//
//  Created by Петраков Павел Константинович on 08.09.2021.
//
//

import Foundation
import CoreData


extension CoreDataTaskType {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataTaskType> {
    return NSFetchRequest<CoreDataTaskType>(entityName: "CoreDataTaskType")
  }
  
  @NSManaged public var imageName: String?
  @NSManaged public var imageColorHex: String?
  @NSManaged public var ordernumber: Double
  @NSManaged public var text: String?
  @NSManaged public var uid: String?
  @NSManaged public var status: String?
}
