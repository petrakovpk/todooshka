//
//  SettingsItem.swift
//  Todooshka
//
//  Created by Pavel Petakov on 18.06.2022.
//

import RxDataSources

struct SettingItem {
  var text: String
  var rightText: String = ""
  var type: SettingsType
}

extension SettingItem: IdentifiableType {
  var identity: String {
    type.rawValue + rightText
  }
}

extension SettingItem: Equatable {
  static func == (lhs: SettingItem, rhs: SettingItem) -> Bool {
    lhs.text == rhs.text
  }
}
