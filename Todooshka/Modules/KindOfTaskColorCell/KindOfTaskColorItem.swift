//
//  KindOfTaskColorItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 25.09.2022.
//

import RxDataSources

struct KindOfTaskColorItem: IdentifiableType, Equatable {
  var identity: String { color.hexString + isSelected.string }

  var color: UIColor
  var isSelected: Bool
}
