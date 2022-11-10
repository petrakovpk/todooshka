//
//  Icons.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.04.2022.
//

import UIKit
import RxDataSources

enum Icon: String, IdentifiableType, Equatable {
  // MARK: - Icons
  case bank = "Bank"
  case bookSaved = "BookSaved"
  case briefcase = "Briefcase"
  case dumbbell = "Dumbbell"
  case emojiHappy = "EmojiHappy"
  case gasStation = "GasStation"
  case house = "House"
  case lovely = "Lovely"
  case moon = "Moon"
  case notificationBing = "NotificationBing"
  case pet = "Pet"
  case profile2user = "Profile2user"
  case ship = "Ship"
  case shop = "Shop"
  case sun = "Sun"
  case teacher = "Teacher"
  case tree = "Tree"
  case unlimited = "Unlimited"
  case videoVertical = "VideoVertical"
  case wallet = "Wallet"
  case weight = "Weight"

  // MARK: - Image
  var image: UIImage {
    return UIImage(named: self.rawValue)!.template
  }

  // MARK: - Identity
  var identity: String { return self.rawValue }
}
