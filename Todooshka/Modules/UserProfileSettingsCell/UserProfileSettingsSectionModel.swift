//
//  UserProfileSettingsSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//

import RxDataSources
import UIKit

enum SettingsType {
  case deletedTaskListIsRequired, deletedTaskTypeListIsRequired, authIsRequired
}

struct SettingsItem: IdentifiableType, Equatable  {
  
  var identity: String { return UUID().uuidString }
  
  var imageName: String
  var text: String
  var type: SettingsType
  
  static func == (lhs: SettingsItem, rhs: SettingsItem) -> Bool {
    return lhs.text == rhs.text
  }
}

struct UserProfileSettingsSectionModel: AnimatableSectionModelType {
  
  var identity: String {
    return header
  }
  
  var header: String
  var items: [SettingsItem]
  
  init(header: String, items: [SettingsItem]) {
    self.header = header
    self.items = items
  }
  
  init(original: UserProfileSettingsSectionModel, items: [SettingsItem]) {
    self = original
    self.items = items
  }
}
