//
//  Publication.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.04.2023.
//

import FirebaseAuth

enum PublicationStatus: String {
  case unpublished
  case published
}

struct Publication {
  let uuid: UUID
  var userUID: String? = Auth.auth().currentUser?.uid
  var taskUUID: UUID?
  var publicKindUUID: UUID?
  var created: Date = Date()
  var published: Date?
  var text: String? = ""
  var status: PublicationStatus = .unpublished
}

extension Publication: Equatable {

}
