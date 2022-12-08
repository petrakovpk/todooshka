//
//  SettingsCellSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//

import UIKit
import RxDataSources

struct SettingsCellSectionModel: AnimatableSectionModelType {
  var identity: String {
    header
  }

  var header: String
  var items: [SettingsItem]

  init(header: String, items: [SettingsItem]) {
    self.header = header
    self.items = items
  }

  init(original: SettingsCellSectionModel, items: [SettingsItem]) {
    self = original
    self.items = items
  }
}
