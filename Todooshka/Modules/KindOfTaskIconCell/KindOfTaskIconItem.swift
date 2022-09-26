//
//  KindOfTaskIconItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 25.09.2022.
//

import RxDataSources

struct KindOfTaskIconItem: IdentifiableType, Equatable {
  
  var identity: String { icon.rawValue + isSelected.string }
  
  var icon: Icon
  var isSelected: Bool

}
