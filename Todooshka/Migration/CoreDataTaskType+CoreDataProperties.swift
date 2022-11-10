//
//  CoreDataTaskType+CoreDataProperties.swift
//  
//
//  Created by Pavel Petakov on 10.10.2022.
//
//

import Foundation
import CoreData

extension CoreDataTaskType {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataTaskType> {
        return NSFetchRequest<CoreDataTaskType>(entityName: "CoreDataTaskType")
    }

    @NSManaged public var imageColorHex: String?
    @NSManaged public var imageName: String?
    @NSManaged public var ordernumber: Double
    @NSManaged public var status: String?
    @NSManaged public var text: String?
    @NSManaged public var uid: String?
}
