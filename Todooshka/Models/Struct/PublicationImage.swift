//
//  PublicationImage.swift
//  DragoDo
//
//  Created by Pavel Petakov on 12.05.2023.
//


import UIKit

struct PublicationImage {
  let uuid: UUID
  let publicationUUID: UUID
  let image: UIImage
}

extension PublicationImage: Equatable {
  static func == (lhs: PublicationImage, rhs: PublicationImage) -> Bool {
    lhs.uuid == rhs.uuid
    && lhs.publicationUUID == rhs.publicationUUID
    && lhs.image == rhs.image
  }
}


