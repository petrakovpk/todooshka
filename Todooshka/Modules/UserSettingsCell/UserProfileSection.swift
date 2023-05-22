//
//  UserProfileSection.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import Foundation
import RxDataSources
import UIKit

struct UserProfileSection: AnimatableSectionModelType {
  var identity: String {
    return header
  }

  var header: String
  var items: [UserProfileItem]

  init(header: String, items: [UserProfileItem]) {
    self.header = header
    self.items = items
  }

  init(original: UserProfileSection, items: [UserProfileItem]) {
    self = original
    self.items = items
  }
}
