//
//  QuestCategory.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.05.2023.
//

import CoreData
import FirebaseAuth
import RxDataSources
import UIKit

struct PublicKind {
  var uuid: UUID
  var image: UIImage
  var text: String
}

extension PublicKind: IdentifiableType {
  var identity: String {
    return uuid.uuidString
  }
}

extension PublicKind: Equatable {
  static func == (lhs: PublicKind, rhs: PublicKind) -> Bool {
    lhs.uuid == rhs.uuid
    && lhs.image == rhs.image
    && lhs.text == rhs.text
  }
}

