//
//  CoreDataTaskType+CoreDataProperties.swift
//  
//
//  Created by Петраков Павел Константинович on 18.07.2021.
//
//

import Foundation
import CoreData


extension CoreDataTaskType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataTaskType> {
        return NSFetchRequest<CoreDataTaskType>(entityName: "CoreDataTaskType")
    }

    @NSManaged public var uid: String?
    @NSManaged public var systemimagename: String?
    @NSManaged public var text: String?
    @NSManaged public var ordernumber: NSNumber?

}
