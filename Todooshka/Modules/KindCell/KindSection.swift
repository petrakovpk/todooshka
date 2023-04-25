//
//  KindOfTaskSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.05.2022.
//

import RxDataSources

struct KindSection: AnimatableSectionModelType {
  var header: String
  var items: [KindSectionItem]
  
  init(header: String, items: [KindSectionItem]) {
    self.header = header
    self.items = items
  }
  
  init(original: KindSection, items: [KindSectionItem]) {
    self = original
    self.items = items
  }
}


extension KindSection: IdentifiableType {
  var identity: String {
    return header
  }
}
