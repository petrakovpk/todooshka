//
//  TaskType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 27.06.2021.
//

import Foundation
import Firebase
import UIKit
import RxDataSources

class TaskType: IdentifiableType, Equatable  {

    var identity: String { return self.UID }
    var UID: String
    var image: UIImage {
        switch self.UID {
        case "family":
            return UIImage(named: "profile-2user")!.withRenderingMode(.alwaysTemplate)
        case "business":
            return UIImage(named: "monitor")!.withRenderingMode(.alwaysTemplate)
        case "house":
            return UIImage(named: "home")!.withRenderingMode(.alwaysTemplate)
        case "love":
            return UIImage(named: "lovely")!.withRenderingMode(.alwaysTemplate)
        case "work":
            return UIImage(named: "briefcase")!.withRenderingMode(.alwaysTemplate)
        case "sport":
            return UIImage(named: "weight")!.withRenderingMode(.alwaysTemplate)
        default:
            return UIImage(systemName: self.systemImageName)!
        }
    }
    var systemImageName: String
    var text: String
    var orderNumber: Int
    
    init(UID: String, systemImageName: String, text: String, orderNumber: Int) {
        self.UID = UID
        self.systemImageName = systemImageName
        self.text = text
        self.orderNumber = orderNumber
    }
    
    init?(snapshot: DataSnapshot) {
        guard let snapshotDict = snapshot.value as? [String: Any] else { return nil }
        guard
            let systemImageName = snapshotDict["systemImageName"] as? String,
            let text = snapshotDict["text"] as? String,
            let orderNumber = snapshotDict["orderNumber"] as? Int
        else { return nil }
        self.UID = snapshot.key
        self.systemImageName = systemImageName
        self.text = text
        self.orderNumber = orderNumber
    }
    
    init?(coreDataTaskType: CoreDataTaskType) {
        
        guard
            let UID = coreDataTaskType.uid,
            let systemImageName = coreDataTaskType.systemimagename,
            let text = coreDataTaskType.text,
            let orderNumber = coreDataTaskType.ordernumber
        else { return nil}
        
        self.UID = UID
        self.systemImageName = systemImageName
        self.text = text
        self.orderNumber = Int(truncating: orderNumber)
    }
    
    static func == (lhs: TaskType, rhs: TaskType) -> Bool {
        return lhs.UID == rhs.UID
    }
}
