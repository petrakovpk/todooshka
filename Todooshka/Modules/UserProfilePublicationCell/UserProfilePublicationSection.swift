//
//  UserProfilePublicationSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 01.05.2023.
//

import RxDataSources

struct UserProfilePublicationSection: AnimatableSectionModelType {
  var header: String
  var items: [UserProfilePublicationItem]
  
  init(header: String, items: [UserProfilePublicationItem]) {
    self.header = header
    self.items = items
  }
  
  init(original: UserProfilePublicationSection, items: [UserProfilePublicationItem]) {
    self = original
    self.items = items
  }
}

extension UserProfilePublicationSection: IdentifiableType {
  var identity: String {
    return header
  }
}

