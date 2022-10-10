//
//  CoreDataTask+CoreDataProperties.swift
//  
//
//  Created by Pavel Petakov on 07.10.2022.
//
//

import Foundation
import CoreData


extension CoreDataTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataTask> {
        NSFetchRequest<CoreDataTask>(entityName: "CoreDataTask")
    }

    @NSManaged public var closedTimeIntervalSince1970: NSNumber?
    @NSManaged public var createdTimeIntervalSince1970: NSNumber?
    @NSManaged public var lastmodifiedtimeintervalsince1970: Double
    @NSManaged public var longText: String?
    @NSManaged public var orderNumber: Double
    @NSManaged public var status: String?
    @NSManaged public var text: String?
    @NSManaged public var type: String?
    @NSManaged public var uid: String?
    @NSManaged public var userUID: String?
}
