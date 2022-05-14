//
//  TypeLargeCollectionViewCellSectionModelItem.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.05.2022.
//

import RxDataSources

struct TypeLargeCollectionViewCellSectionModelItem: IdentifiableType, Equatable {
  let type: TaskType
  let isSelected: Bool
  
  //MARK: - Identity
  var identity: String {
    return type.UID
  }
  
  // MARK: - Equatable
  static func == (lhs: TypeLargeCollectionViewCellSectionModelItem, rhs: TypeLargeCollectionViewCellSectionModelItem) -> Bool {
    return lhs.isSelected == rhs.isSelected
  }
}

