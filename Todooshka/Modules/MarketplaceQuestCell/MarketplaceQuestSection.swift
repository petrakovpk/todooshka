//
//  ThemeSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import RxDataSources

enum MarketplaceQuestSectionType {
  case personal
  case recommended
  case category(category: PublicKind)
}

extension MarketplaceQuestSectionType: Equatable {
  
}

struct MarketplaceQuestSection: AnimatableSectionModelType {
  var header: String
  var type: MarketplaceQuestSectionType
  var items: [MarketplaceQuestSectionItem]
  
  init(header: String, type: MarketplaceQuestSectionType, items: [MarketplaceQuestSectionItem]) {
    self.header = header
    self.type = type
    self.items = items
  }
  
  init(original: MarketplaceQuestSection, items: [MarketplaceQuestSectionItem]) {
    self = original
    self.items = items
  }
}

extension MarketplaceQuestSection: IdentifiableType {
  var identity: String {
    header
  }
}
