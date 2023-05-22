//
//  ThemeItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import RxDataSources
import UIKit

struct MarketplaceQuestSectionItem {
  let quest: Quest
  let image: UIImage
}

// MARK: - Identity
extension MarketplaceQuestSectionItem: IdentifiableType {
  var identity: String {
    quest.uuid.uuidString
  }
}

// MARK: - Equatable
extension MarketplaceQuestSectionItem: Equatable {
  static func == (lhs: MarketplaceQuestSectionItem, rhs: MarketplaceQuestSectionItem) -> Bool {
    lhs.quest == rhs.quest
  }
}
