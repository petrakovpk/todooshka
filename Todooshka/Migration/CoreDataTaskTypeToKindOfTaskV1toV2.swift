//
//  CoreDataTaskTypeToKindOfTaskV1toV2.swift
//  Todooshka
//
//  Created by Pavel Petakov on 10.10.2022.
//

import CoreData
import Firebase

class CoreDataTaskTypeToKindOfTaskV1toV2: NSEntityMigrationPolicy {

  override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {

    try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

    guard let destinationKindOfTask = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).last else { return }

    let imageColorHex = sInstance.primitiveValue(forKey: "imageColorHex") as? String
    let imageName = sInstance.primitiveValue(forKey: "imageName") as? String
    let ordernumber = sInstance.primitiveValue(forKey: "ordernumber") as? Int
    let status = sInstance.primitiveValue(forKey: "status") as? String
    let text = sInstance.primitiveValue(forKey: "text") as? String
    let uid = sInstance.primitiveValue(forKey: "uid") as? String

    destinationKindOfTask.setValue(imageColorHex, forKey: "colorHexString")
    destinationKindOfTask.setValue(imageName, forKey: "iconRawValue")
    destinationKindOfTask.setValue(ordernumber, forKey: "index")
    destinationKindOfTask.setValue(false, forKey: "isStyleLocked")
    destinationKindOfTask.setValue(Date().timeIntervalSince1970, forKey: "lastModified")
    destinationKindOfTask.setValue(status, forKey: "statusRawValue")
    destinationKindOfTask.setValue("Empty", forKey: "styleRawValue")
    destinationKindOfTask.setValue(text, forKey: "text")
    destinationKindOfTask.setValue(uid, forKey: "uid")
    destinationKindOfTask.setValue(Auth.auth().currentUser?.uid, forKey: "userUID")

    manager.associate(sourceInstance: sInstance, withDestinationInstance: destinationKindOfTask, for: mapping)
  }
}
