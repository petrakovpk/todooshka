//
//  SettingsItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 18.06.2022.
//

import RxDataSources

struct SettingsItem: IdentifiableType, Equatable {
  var identity: String { return UUID().uuidString }

  var imageName: String
  var text: String
  var type: SettingsType

  static func == (lhs: SettingsItem, rhs: SettingsItem) -> Bool {
    return lhs.text == rhs.text
  }
}
