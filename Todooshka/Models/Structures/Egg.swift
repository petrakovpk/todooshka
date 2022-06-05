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
  var cracks: CrackType

  // MARK: - Computed properties
  var identity: String { UID }
  
  var secondsPassed: Double {
    Date().timeIntervalSince1970 - created.timeIntervalSince1970
  }
  
  var image: UIImage? {
    return UIImage(named: "яйцо_" + clade.stringForImage + "_" + cracks.stringForImage)
  }
  
  func getImageForCracks(cracks: CrackType) -> UIImage? {
    return UIImage(named: "яйцо_" + clade.stringForImage + "_" + cracks.stringForImage)
  }

  // MARK: - Init
  init(UID: String, clade: BirdClade, cracks: CrackType, created: Date) {
    self.UID = UID
    self.clade = clade
    self.created = created
    self.cracks = cracks
  }
}
