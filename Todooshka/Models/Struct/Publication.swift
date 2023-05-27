//
//  Publication.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.04.2023.
//

import FirebaseAuth

struct Publication {
  let uuid: UUID
  var text: String?
  var isPublic: Bool = false
  var created: Date = Date()
  var published: Date?
  var userUID: String? = Auth.auth().currentUser?.uid
}

extension Publication: Equatable {

}
