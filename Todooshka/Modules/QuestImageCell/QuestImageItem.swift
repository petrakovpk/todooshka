//
//  QuestImageItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.05.2023.
//

import RxDataSources

enum QuestImageItem {
  case addPhoto
  case questImage(questImage: QuestImage)
}

extension QuestImageItem: IdentifiableType {
  var identity: String {
    switch self {
    case .addPhoto:
      return "addPhoto"
    case .questImage(let questImage):
      return questImage.identity
    }
  }
}

extension QuestImageItem: Equatable {
  static func == (lhs: QuestImageItem, rhs: QuestImageItem) -> Bool {
    switch (lhs, rhs) {
    case (.questImage(let lQuestImage), .questImage(let rQuestImage)):
      return lQuestImage.identity == rQuestImage.identity
    case (.addPhoto, .addPhoto):
      return true
    default:
      return false
    }
  }
}
