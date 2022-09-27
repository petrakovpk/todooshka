//
//  KindOfTaskItem.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.05.2022.
//

import RxDataSources

struct KindOfTaskItem: IdentifiableType, Equatable {
  let kindOfTask: KindOfTask
  let isSelected: Bool
  
  //MARK: - Identity
  var identity: String {
    kindOfTask.UID
  }
  
  // MARK: - Equatable
  static func == (lhs: KindOfTaskItem, rhs: KindOfTaskItem) -> Bool {
     lhs.isSelected == rhs.isSelected
  }
}

