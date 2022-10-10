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
    
    print("1234 start")
    
    try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
    
    // 1
//    let description = NSEntityDescription.entity(forEntityName: "ImageAttachment", in: manager.destinationContext)
//    let newAttachment = ImageAttachment(entity: description!, insertInto: manager.destinationContext)
//
//    // 2
//    func traversePropertyMappings(block:(NSPropertyMapping, String) -> ()) throws {
//      if let attributeMappings = mapping.attributeMappings {
//        for propertyMapping in attributeMappings {
//          if let destinationName = propertyMapping.name {
//            block(propertyMapping, destinationName)
//          } else {
//            // 3
//            let message =
//            "Attribute destination not configured properly"
//            let userInfo =
//            [NSLocalizedFailureReasonErrorKey: message]
//            throw NSError(domain: errorDomain,
//                          code: 0, userInfo: userInfo)
//          } }
//      } else {
//        let message = "No Attribute Mappings found!"
//        let userInfo = [NSLocalizedFailureReasonErrorKey: message]
//        throw NSError(domain: errorDomain,
//                      } }
//          // 4
//          code: 0, userInfo: userInfo)
//          try traversePropertyMappings {
//            propertyMapping, destinationName in
//            if let valueExpression = propertyMapping.valueExpression {
//              let context: NSMutableDictionary = ["source": sInstance]
//              guard let destinationValue =
//                valueExpression.expressionValue(with: sInstance,
//                                                context: context) else {
//              newAttachment.setValue(destinationValue,
//          }
//          } }
//          // 5
//          return
//          forKey: destinationName)
//          if let image = sInstance.value(forKey: "image") as? UIImage {
//            newAttachment.setValue(image.size.width, forKey: "width")
//            newAttachment.setValue(image.size.height, forKey: "height")
//          }
//          // 6
//          let body =
//            sInstance.value(forKeyPath: "note.body") as? NSString ?? ""
//          newAttachment.setValue(body.substring(to: 80),
//                                 forKey: "caption")
//          // 7
//          manager.associate(sourceInstance: sInstance,
//                            withDestinationInstance: newAttachment,
//                            for: mapping)
    
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
