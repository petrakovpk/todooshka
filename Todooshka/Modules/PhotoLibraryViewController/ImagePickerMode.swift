//
//  ExtImagePickerMode.swift
//  DragoDo
//
//  Created by Pavel Petakov on 08.05.2023.
//

import Foundation

enum ImagePickerMode {
  case publication(publication: Publication)
  case questPreviewImage(quest: Quest)
  case questAuthorImages(quest: Quest)
  case userExtData(userExtData: UserExtData)
}

extension ImagePickerMode: Equatable {
  static func == (lhs: ImagePickerMode, rhs: ImagePickerMode) -> Bool {
    switch (lhs, rhs) {
    case (.publication(let lPublication), .publication(let rPublication)):
      return lPublication == rPublication
    case (.userExtData(let lUserExtData), .userExtData(let rUserExtData)):
      return lUserExtData == rUserExtData
    case (.questPreviewImage(let lQuest), .questPreviewImage(let rQuest)):
      return lQuest == rQuest
    case (.questAuthorImages(let lQuest), .questAuthorImages(let rQuest)):
      return lQuest == rQuest
    default:
      return false
    }
  }
}
