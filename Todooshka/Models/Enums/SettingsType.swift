//
//  SettingsType.swift
//  Todooshka
//
//  Created by Pavel Petakov on 18.06.2022.
//
import UIKit

enum SettingsType: String {
  case authIsRequired
  case openProfileIsRequired
  case logOutIsRequired
 
  case syncDataIsRequired
  
  case deleteThemeIsRequired
  case deletedKindListIsRequired
  case deletedTaskListIsRequired
  
  case supportIsRequired
  
  case sendForVerificationIsRequired
  
  case camera
  case photo
  
  case draftIsRequired
  case deleteIsRequired
  
  case edit
  
  var image: UIImage {
    switch self {
    case .photo:
      return Icon.gallery.image
    case .camera:
      return Icon.camera.image
    case .authIsRequired:
      return Icon.userSquare.image
    case .logOutIsRequired:
      return Icon.logout.image
    case .sendForVerificationIsRequired:
      return Icon.arrowUp.image
    case .deletedKindListIsRequired,
        .deletedTaskListIsRequired,
        .deleteThemeIsRequired:
      return Icon.trash.image
    case .supportIsRequired:
      return Icon.messageNotif.image
    case .openProfileIsRequired:
      return Icon.userSquare.image
    case .draftIsRequired:
      return Icon.ghost.image
    case .deleteIsRequired:
      return Icon.trash.image
    case .edit:
      return Icon.editWithSquare.image
    default:
      return UIImage()
    }
  }
}
