//
//  KindOfTaskForBirdItem.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.05.2022.
//

import RxDataSources

struct KindOfTaskForBirdItem: IdentifiableType, Equatable {
  
  let kindOfTask: KindOfTask
  let isPlusButton: Bool
  let isRemovable: Bool
  
  //MARK: - Identity
  var identity: String { kindOfTask.UID }
  
  // MARK: - Equatable
  static func == (lhs: KindOfTaskForBirdItem, rhs: KindOfTaskForBirdItem) -> Bool {
    lhs.kindOfTask.UID == rhs.kindOfTask.UID
    && lhs.isRemovable == rhs.isRemovable
  }
}
