//
//  QuestImageSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.05.2023.
//

import UIKit
import RxDataSources

struct QuestImageSection: AnimatableSectionModelType {
  var header: String
  var items: [QuestImageItem]

  init(header: String, items: [QuestImageItem]) {
    self.header = header
    self.items = items
  }

  init(original: QuestImageSection, items: [QuestImageItem]) {
    self = original
    self.items = items
  }
}

extension QuestImageSection: IdentifiableType {
  var identity: String {
    return header
  }
}
