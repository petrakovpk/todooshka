//
//  SettingsCellSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//

import UIKit
import RxDataSources

struct SettingSection: AnimatableSectionModelType {
  var header: String
  var items: [SettingItem]

  init(header: String, items: [SettingItem]) {
    self.header = header
    self.items = items
  }

  init(original: SettingSection, items: [SettingItem]) {
    self = original
    self.items = items
  }
}

extension SettingSection: IdentifiableType {
  var identity: String {
    return header
  }
}
