//
//  Task+StorageManager.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//

import RxCocoa
import RxSwift

extension Task {
  
  func fetchFirstFromStorage() -> Observable<Task?> {
    return StorageManager.shared.performFetchRequest(persistableObject: self).map { $0.first }
  }
  
  func fetchAllFromStorage() -> Observable<[Task]> {
    return StorageManager.shared.performFetchRequest(persistableObject: self)
  }
  
  func updateToStorage() -> Observable<Void> {
    return StorageManager.shared.performUpdateRequest(persistableObject: self)
  }
}

