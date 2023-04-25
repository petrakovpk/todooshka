//
//  KindOfTaskColorItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 25.09.2022.
//

import RxDataSources

struct KindColorItem: Equatable {
  var color: UIColor
  var isSelected: Bool
}

extension KindColorItem: IdentifiableType {
  var identity: String {
    return color.hexString + isSelected.string
  }
}
