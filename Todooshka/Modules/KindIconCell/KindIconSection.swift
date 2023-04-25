//
//  KindOfTaskIconSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import RxDataSources
import UIKit

struct KindIconSection: AnimatableSectionModelType {
  var identity: String { header }
  var header: String
  var items: [KindIconItem]

  init(header: String, items: [KindIconItem]) {
    self.header = header
    self.items = items
  }

  init(original: KindIconSection, items: [KindIconItem]) {
    self = original
    self.items = items
  }
}
