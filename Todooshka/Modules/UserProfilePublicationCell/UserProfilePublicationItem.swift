//
//  UserProfilePublicationItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 01.05.2023.
//

import RxDataSources

struct UserProfilePublicationItem {
  var publication: Publication
  var publicationImage: PublicationImage?
  var viewsCount: Int
}

// MARK: - IdentifiableType
extension UserProfilePublicationItem: IdentifiableType {
  var identity: String {
    publication.uuid.uuidString + (publicationImage?.uuid.uuidString ?? "")
  }
}

// MARK: - Equatable
extension UserProfilePublicationItem: Equatable {
  static func == (lhs: UserProfilePublicationItem, rhs: UserProfilePublicationItem) -> Bool {
    lhs.identity == rhs.identity &&
    lhs.publication == rhs.publication &&
    lhs.publicationImage == rhs.publicationImage &&
    lhs.viewsCount == rhs.viewsCount
  }
}

