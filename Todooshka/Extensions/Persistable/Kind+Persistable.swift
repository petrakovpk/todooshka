//
//  Kind+Persistable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//

import CoreData
import RxSwift
import RxCocoa

extension Kind: Persistable {
  typealias T = NSManagedObject

  static var entityName: String {
    return "Kind"
  }

  static var primaryAttributeName: String {
    return "uuid"
  }

  init?(entity: T) {
    guard
      let uuid = entity.value(forKey: "uuid") as? UUID,
      let index = entity.value(forKey: "index") as? Int,
      let text = entity.value(forKey: "text") as? String,
      let isEmptyKind = entity.value(forKey: "isEmptyKind") as? Bool
    else { return nil }

    self.uuid = uuid
    self.index = index
    self.text = text
    self.isEmptyKind = isEmptyKind

    userUID = entity.value(forKey: "userUID") as? String

    // color
    if let colorHexString = entity.value(forKey: "colorHexString") as? String, let color = UIColor(hexString: colorHexString) {
      self.color = color
    } else {
      self.color = UIColor.systemGray
    }

    // icon
    if let iconRawValue = entity.value(forKey: "iconRawValue") as? String, let icon = Icon(rawValue: iconRawValue) {
      self.icon = icon
    } else {
      self.icon = .unlimited
    }

    // status
    if let statusRawValue = entity.value(forKey: "statusRawValue") as? String, let status = KindOfTaskStatus(rawValue: statusRawValue) {
      self.status = status
    } else {
      self.status = .active
    }

  }

  func update(_ entity: T) {
    entity.setValue(uuid, forKey: "uuid")
    entity.setValue(color?.hexString, forKey: "colorHexString")
    entity.setValue(icon?.rawValue, forKey: "iconRawValue")
    entity.setValue(index, forKey: "index")
    entity.setValue(status.rawValue, forKey: "statusRawValue")
    entity.setValue(text, forKey: "text")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(isEmptyKind, forKey: "isEmptyKind")
  }

  func save(_ entity: T) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
