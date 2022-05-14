//
//  Egg.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.03.2022.
//

import UIKit
import Differentiator

struct Egg {
  
  // MARK: - Properties
  let UID: String // task UID
  let created: Date
  var clade: BirdClade
  

  // MARK: - Computed properties
  var identity: String { UID }
  
  var secondsPassed: Double {
    Date().timeIntervalSince1970 - created.timeIntervalSince1970
  }
  
  var cracks: CrackType {
    switch secondsPassed / 3600 {
    case 0...6:
      return .NoCrack
    case 7...12:
      return .OneCrack
    case 13...23:
      return .ThreeCracks
    default:
      return .ThreeCracks
    }
  }
  
  var image: UIImage? {
    return UIImage(named: "яйцо_" + clade.stringForImage + "_" + cracks.stringForImage)
  }
  
  func getImageForCracks(cracks: CrackType) -> UIImage? {
    return UIImage(named: "яйцо_" + clade.stringForImage + "_" + cracks.stringForImage)
  }

  
  // MARK: - Init
  init(UID: String, clade: BirdClade, created: Date) {
    self.UID = UID
    self.clade = clade
    self.created = created
  }
  
  
  // MARK: - Equatable
//  static func == (lhs: Egg, rhs: Egg) -> Bool {
//    return lhs.identity == rhs.identity
//  }
//  
//  // MARK: - Hashable
//  func hash(into hasher: inout Hasher) {
//      hasher.combine(taskUID)
//  }
}
