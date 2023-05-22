//
//  SubscriptionSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import UIKit
import RxDataSources

struct SubscriptionSection: AnimatableSectionModelType {
  var header: String
  var items: [SubscriptionItem]

  init(header: String, items: [SubscriptionItem]) {
    self.header = header
    self.items = items
  }

  init(original: SubscriptionSection, items: [SubscriptionItem]) {
    self = original
    self.items = items
  }
}

extension SubscriptionSection: IdentifiableType {
  var identity: String {
    return header
  }
}
