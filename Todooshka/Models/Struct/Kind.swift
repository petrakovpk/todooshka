//
//  KindOfTask.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 27.06.2021.
//

import CoreData
import FirebaseAuth
import RxDataSources
import UIKit

struct Kind {
  var uuid: UUID
  var color: UIColor?
  var icon: Icon?
  var index: Int = 0
  var status: KindOfTaskStatus = .active
  var text: String = ""
  var userUID: String? = Auth.auth().currentUser?.uid
  var isEmptyKind: Bool = false 
}

extension Kind: IdentifiableType {
  var identity: String {
    return uuid.uuidString
  }
}

extension Kind: Equatable {
  static func == (lhs: Kind, rhs: Kind) -> Bool {
    lhs.uuid == rhs.uuid
    && lhs.icon == rhs.icon
    && lhs.color == rhs.color
    && lhs.text == rhs.text
    && lhs.index == rhs.index
    && lhs.status == rhs.status
    && lhs.userUID == rhs.userUID
    && lhs.isEmptyKind == rhs.isEmptyKind
  }
}
