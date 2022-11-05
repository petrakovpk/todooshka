//
//  BirdFirebase.swift
//  Todooshka
//
//  Created by Pavel Petakov on 29.09.2022.
//

import CoreData
import Firebase
import Differentiator

struct BirdFirebase: IdentifiableType, Equatable {

  // MARK: - IdentifiableType
  var identity: String { UID }

  // MARK: - Properties
  let UID: String

  var userUID: String? = Auth.auth().currentUser?.uid { didSet { lastModified = Date()} }
  var isBought: Bool = false { didSet { lastModified = Date()} }

  var lastModified: Date = Date()

  // MARK: - Equatable
  static func == (lhs: BirdFirebase, rhs: BirdFirebase) -> Bool {
    lhs.identity == rhs.identity
    && lhs.isBought == rhs.isBought
    && lhs.userUID == rhs.userUID
    && lhs.lastModified == rhs.lastModified
  }

}

// MARK: - Firebase
extension BirdFirebase {
  typealias D = DataSnapshot

  var data: [AnyHashable: Any] {
    [
      "isBought": isBought,
      "lastModified": lastModified.timeIntervalSince1970
    ]
  }

  init?(snapshot: D) {

    // check
    guard let dict = snapshot.value as? NSDictionary,
          let isBought = dict.value(forKey: "isBought") as? Bool,
          let lastModifiedTimeInterval = dict.value(forKey: "lastModified") as? TimeInterval
    else { return nil }

    // init
    self.UID = snapshot.key
    self.isBought = isBought
    self.lastModified = Date(timeIntervalSince1970: lastModifiedTimeInterval)
    self.userUID = Auth.auth().currentUser?.uid
  }
}
