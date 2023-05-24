//
//  Deal.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import CoreData
import FirebaseAuth
import RxDataSources
import UIKit

enum QuestStatus: String {
  case draft
  case onApproval
  case published
}

struct Quest {
  let uuid: UUID
  var name: String = ""
  var description: String = ""
  var categoryUUID: UUID?
  var userUID: String? = Auth.auth().currentUser?.uid
  var status: QuestStatus
  var previewImage: UIImage?
}

// MARK: - IdentifiableType
extension Quest: IdentifiableType {
  var identity: String {
    uuid.uuidString
  }
}

extension Quest: Equatable {
  
}
