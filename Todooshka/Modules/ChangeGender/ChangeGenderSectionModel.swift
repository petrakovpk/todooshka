//
//  ChangeGenderSectionModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import Foundation
import RxDataSources
import UIKit

struct ChangeGenderSectionModel: AnimatableSectionModelType {

  var identity: String {
    return header
  }

  var header: String
  var items: [ChangeGenderItem]

  init(header: String, items: [ChangeGenderItem]) {
    self.header = header
    self.items = items
  }

  init(original: ChangeGenderSectionModel, items: [ChangeGenderItem]) {
    self = original
    self.items = items
  }
}
