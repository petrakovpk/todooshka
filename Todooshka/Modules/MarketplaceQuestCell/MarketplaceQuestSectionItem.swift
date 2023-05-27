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
}

// MARK: - Identity
extension MarketplaceQuestSectionItem: IdentifiableType {
  var identity: String {
    quest.uuid.uuidString
  }
}

// MARK: - Equatable
extension MarketplaceQuestSectionItem: Equatable {

}
