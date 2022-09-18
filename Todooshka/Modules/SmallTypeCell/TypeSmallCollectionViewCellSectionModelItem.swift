//
//  TypeSmallCollectionViewCellSectionModelItem.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.05.2022.
//

import RxDataSources

struct TypeSmallCollectionViewCellSectionModelItem: IdentifiableType, Equatable {
  
  let kindOfTask: KindOfTask
  let isSelected: Bool
  let isEnabled: Bool
  
  //MARK: - Identity
  var identity: String {
    return kindOfTask.UID
  }
  
  // MARK: - Equatable
  static func == (lhs: TypeSmallCollectionViewCellSectionModelItem, rhs: TypeSmallCollectionViewCellSectionModelItem) -> Bool {
    return lhs.isSelected == rhs.isSelected
    && lhs.isEnabled == rhs.isEnabled
  }
}
