//
//  Task.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 20.05.2021.
//

import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import RxDataSources

struct Task {
  let uuid: UUID
  var text: String = ""
  var description: String = ""
  var status: TaskStatus
  var index: Int = 0
  var created = Date()
  var planned = Date().endOfDay
  var completed: Date?
  var kindUUID: UUID
  var userUID: String? = Auth.auth().currentUser?.uid
  
  var secondsLeft: Double {
    max(planned.timeIntervalSince1970 - Date().startOfDay.timeIntervalSince1970, 0)
  }
  
}

extension Task: IdentifiableType {
  var identity: String {
    return uuid.uuidString
  }
}


