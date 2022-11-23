//
//  Icons.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.04.2022.
//

import UIKit
import RxDataSources

enum Icon: String {
  case addSquare
  case arrowBottom
  case arrowLeft
  case arrowLeftCustom
  case arrowRightCustom
  case arrowTop
  case bank
  case bookSaved
  case box
  case box3d
  case boxAdd
  case boxTick
  case briefcase
  case call
  case clipboardTick
  case dumbbell
  case edit
  case editWithSquare
  case emojiHappy
  case gasStation
  case home
  case home2
  case lampCharge
  case lampChargeCustom
  case lock
  case lockWithRound
  case login
  case logout
  case lovely
  case messageNotif
  case moon
  case notificationBing
  case pet
  case plus
  case plusCustom
  case point
  case profile2user
  case refreshCircle
  case remove
  case rotateRight
  case round
  case selectedRound
  case settings
  case settingsGear
  case ship
  case shop
  case sms
  case sort
  case sun
  case teacher
  case tick
  case tickRound
  case tickSquare
  case timer
  case timerPause
  case trash
  case trashCustom
  case tree
  case unlimited
  case userSquare
  case videoVertical
  case wallet
  case weight

  // MARK: - Image
  var image: UIImage {
    UIImage(named: "\(self.rawValue)") ?? UIImage()
  }
  
  var isEnabledForKindOfTask: Bool {
    switch self {
    case .bank,
        .bookSaved,
        .briefcase,
        .dumbbell,
        .emojiHappy,
        .gasStation,
        .home,
        .lovely,
        .moon,
        .notificationBing,
        .pet,
        .profile2user,
        .ship,
        .shop,
        .sun,
        .teacher,
        .tree,
        .unlimited,
        .videoVertical,
        .wallet,
        .weight:
      return true
    default:
      return false
    }
  }
}

extension Icon: IdentifiableType {
  var identity: String { self.rawValue }
}
