//
//  FunSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import RxDataSources

struct FunSection {
  var items: [FunItemType]
  
  init(items: [FunItemType]) {
    self.items = items
  }
  
  init(original: FunSection, items: [FunItemType]) {
    self = original
    self.items = items
  }
}

extension FunSection: AnimatableSectionModelType {
  var identity: String {
    items.map { $0.identity }.joined(separator: "")
  }
}
