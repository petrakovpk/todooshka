//
//  KindOfTaskIconItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 25.09.2022.
//

import RxDataSources

struct KindIconItem: Equatable {
  var icon: Icon
  var isSelected: Bool
}


extension KindIconItem: IdentifiableType {
  var identity: String {
    return icon.rawValue + isSelected.string
  }

}
