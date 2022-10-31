//
//  CoreDataTaskToTaskV1toV2.swift
//  Todooshka
//
//  Created by Pavel Petakov on 07.10.2022.
//

import CoreData
import Firebase

class CoreDataTaskToTaskV1toV2: NSEntityMigrationPolicy {
  
  override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {

    try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
  
    guard let destinationTask = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).last else { return }

    let longText = sInstance.primitiveValue(forKey: "longText") as? String
    let orderNumber = sInstance.primitiveValue(forKey: "orderNumber") as? Int
    let statusRawValue = sInstance.primitiveValue(forKey: "status") as? String
    let text = sInstance.primitiveValue(forKey: "text") as? String
    let typeUID = sInstance.primitiveValue(forKey: "type") as? String
    let uid = sInstance.primitiveValue(forKey: "uid") as? String
    let userUID = sInstance.primitiveValue(forKey: "userUID") as? String

    if let closedTimeIntervalSince1970 = sInstance.primitiveValue(forKey: "closedTimeIntervalSince1970") as? TimeInterval {
      destinationTask.setValue(Date(timeIntervalSince1970: closedTimeIntervalSince1970), forKey: "closed")
    }

    if let createdTimeIntervalSince1970 = sInstance.primitiveValue(forKey: "createdTimeIntervalSince1970") as? TimeInterval {
      destinationTask.setValue(Date(timeIntervalSince1970: createdTimeIntervalSince1970), forKey: "created")
    }

    destinationTask.setValue(longText, forKey: "desc")
    destinationTask.setValue(orderNumber, forKey: "index")
    destinationTask.setValue(typeUID, forKey: "kindOfTaskUID")

    if let lastmodifiedtimeintervalsince1970 = sInstance.primitiveValue(forKey: "lastmodifiedtimeintervalsince1970") as? TimeInterval {
      destinationTask.setValue(Date(timeIntervalSince1970: lastmodifiedtimeintervalsince1970), forKey: "lastModified")
    }

    destinationTask.setValue(statusRawValue, forKey: "statusRawValue")
    destinationTask.setValue(text, forKey: "text")
    destinationTask.setValue(uid, forKey: "uid")
    destinationTask.setValue(userUID ?? Auth.auth().currentUser?.uid , forKey: "userUID")

    manager.associate(sourceInstance: sInstance, withDestinationInstance: destinationTask, for: mapping)
  }
}
