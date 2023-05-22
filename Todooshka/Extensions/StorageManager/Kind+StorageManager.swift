//
//  KindOfTask+StorageManager.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//

import RxCocoa
import RxSwift

extension Kind {
  func fetchFirstFromStorage() -> Observable<Kind?> {
    return StorageManager.shared.performFetchRequest(persistableObject: self)
      .map { $0.first }
  }
  
  func fetchAllFromStorage() -> Observable<[Kind]> {
    return StorageManager.shared.performFetchRequest(persistableObject: self)
  }
}

