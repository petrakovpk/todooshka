//
//  User+StorageManager.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//

import FirebaseAuth
import CoreData
import RxCocoa
import RxSwift

extension User {
  func fetchAllKindsFromStorage() -> Observable<[Kind]> {
    let predicate = NSPredicate(format: "userUID == %@", self.uid as CVarArg)
    return StorageManager.shared.managedContext.rx.entities(Kind.self, predicate: predicate)
  }
  
  func fetchUserExtData() -> Observable<UserExtData?> {
    let predicate = NSPredicate(format: "userUID == %@", self.uid as CVarArg)
    return StorageManager.shared.managedContext.rx.entities(UserExtData.self, predicate: predicate)
      .map { $0.first }
  }
}
