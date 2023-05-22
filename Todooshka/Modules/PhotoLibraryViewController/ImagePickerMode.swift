//
//  ExtImagePickerMode.swift
//  DragoDo
//
//  Created by Pavel Petakov on 08.05.2023.
//

import Foundation

enum ImagePickerMode {
  case publication(publication: Publication)
  case quest(quest: Quest)
  case userProfile(extUserData: UserExtData)
}

extension ImagePickerMode: Equatable {
  static func == (lhs: ImagePickerMode, rhs: ImagePickerMode) -> Bool {
    switch (lhs, rhs) {
    case (.publication(let leftPublication), .publication(let rightPublication)):
      return leftPublication.uuid == rightPublication.uuid
    case (.userProfile, .userProfile):
      return true
    default:
      return false
    }
  }
}
