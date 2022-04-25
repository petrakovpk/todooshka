//
//  Icons.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.04.2022.
//

import UIKit
import RxDataSources

enum Icon: String, IdentifiableType, Equatable  {
  
  // MARK: - Icons
  case Bank = "Bank"
  case BookSaved = "BookSaved"
  case Briefcase = "Briefcase"
  case Dumbbell = "Dumbbell"
  case EmojiHappy = "EmojiHappy"
  case GasStation = "GasStation"
  case House = "House"
  case Lovely = "Lovely"
  case Moon = "Moon"
  case NotificationBing = "NotificationBing"
  case Pet = "Pet"
  case Profile2user = "Profile2user"
  case Ship = "Ship"
  case Shop = "Shop"
  case Sun = "Sun"
  case Teacher = "Teacher"
  case Tree = "Tree"
  case Unlimited = "Unlimited"
  case VideoVertical = "VideoVertical"
  case Wallet = "Wallet"
  case Weight = "Weight"
  
  // MARK: - Image
  var image: UIImage {
    return UIImage(named: self.rawValue)!.template
  }
  
  //MARK: - Identity
  var identity: String { return self.rawValue }
}



