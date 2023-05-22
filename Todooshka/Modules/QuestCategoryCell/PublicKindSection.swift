//
//  QuestCategorySection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.05.2023.
//

import UIKit
import RxDataSources

struct PublicKindSection: AnimatableSectionModelType {
  var header: String
  var items: [PublicKindItem]

  init(header: String, items: [PublicKindItem]) {
    self.header = header
    self.items = items
  }

  init(original: PublicKindSection, items: [PublicKindItem]) {
    self = original
    self.items = items
  }
}

extension PublicKindSection: IdentifiableType {
  var identity: String {
    return header
  }
}
