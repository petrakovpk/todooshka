//
//  FollowersSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import UIKit
import RxDataSources

struct FollowersSection: AnimatableSectionModelType {
  var header: String
  var items: [FollowersItem]

  init(header: String, items: [FollowersItem]) {
    self.header = header
    self.items = items
  }

  init(original: FollowersSection, items: [FollowersItem]) {
    self = original
    self.items = items
  }
}

extension FollowersSection: IdentifiableType {
  var identity: String {
    return header
  }
}
