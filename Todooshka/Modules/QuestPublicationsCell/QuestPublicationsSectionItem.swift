//
//  QuestUserResultSectionItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 15.05.2023.
//

import RxDataSources

struct QuestPublicationsSectionItem {
  let publicationImage: PublicationImage
  let publication: Publication
}

extension QuestPublicationsSectionItem: IdentifiableType {
  var identity: String {
    publication.identity
  }
}

extension QuestPublicationsSectionItem: Equatable {
  
}

