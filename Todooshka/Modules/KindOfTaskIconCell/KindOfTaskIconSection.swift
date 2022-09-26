//
//  KindOfTaskIconSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import RxDataSources
import UIKit

struct KindOfTaskIconSection: AnimatableSectionModelType {
  
  var identity: String { header }
  var header: String
  var items: [KindOfTaskIconItem]
  
  init(header: String, items: [KindOfTaskIconItem]) {
    self.header = header
    self.items = items
  }
  
  init(original: KindOfTaskIconSection, items: [KindOfTaskIconItem]) {
    self = original
    self.items = items
  }
}
