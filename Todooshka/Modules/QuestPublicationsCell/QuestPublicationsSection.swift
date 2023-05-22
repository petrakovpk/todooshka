//
//  QuestUserResultSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 15.05.2023.
//

import UIKit
import RxDataSources

struct QuestPublicationsSection: AnimatableSectionModelType {
  var header: String
  var items: [QuestPublicationsSectionItem]

  init(header: String, items: [QuestPublicationsSectionItem]) {
    self.header = header
    self.items = items
  }

  init(original: QuestPublicationsSection, items: [QuestPublicationsSectionItem]) {
    self = original
    self.items = items
  }
}

extension QuestPublicationsSection: IdentifiableType {
  var identity: String {
    return header
  }
}

