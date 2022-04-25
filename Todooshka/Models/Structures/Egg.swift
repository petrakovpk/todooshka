//
//  Egg.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.03.2022.
//

import UIKit
import Differentiator

struct Egg: IdentifiableType, Equatable, Hashable {
  
  // MARK: - Properties
  let UID: String
  let type: EggType
  let taskUID: String
  let position: Int
  let created: Date
  
  // MARK: - Computed properties
  var identity: String {
    return UID
  }
  
  var status: EggStatus {
    let hours = (Date().timeIntervalSince1970 - created.timeIntervalSince1970) / 3600
    switch hours {
    case 0...6:
      return .New
    case 7...12:
      return .OneCrack
    case 13...24:
      return .ThreeCracks
    default:
      return .ThreeCracks
    }
  }
  
  var image: UIImage {
    switch (type, status) {
    case (.Chiken, .New) :
      return UIImage(named: "яйцо_курицы")!
    case (.Chiken, .OneCrack) :
      return UIImage(named: "яйцо_курицы_треснувшее_слабо")!
    case (.Chiken, .ThreeCracks) :
      return UIImage(named: "яйцо_курицы_треснувшее_сильно")!
    case (.Penguin, .New):
      return UIImage(named: "яйцо_пингвина")!
    case (.Penguin, .OneCrack):
      return UIImage(named: "яйцо_пингвина_треснувшее_слабо")!
    case (.Penguin, .ThreeCracks):
      return UIImage(named: "яйцо_пингвина_треснувшее_сильно")!
    case (.Ostrich, .New):
      return UIImage(named: "яйцо_страуса")!
    case (.Ostrich, .OneCrack):
      return UIImage(named: "яйцо_страуса_треснувшее_слабо")!
    case (.Ostrich, .ThreeCracks):
      return UIImage(named: "яйцо_страуса_треснувшее_сильно")!
    case (.Parrot, .New):
      return UIImage(named: "яйцо_попугая")!
    case (.Parrot, .OneCrack):
      return UIImage(named: "яйцо_попугая_треснувшее_слабо")!
    case (.Parrot, .ThreeCracks):
      return UIImage(named: "яйцо_попугая_треснувшее_сильно")!
    case (.Eagle, .New):
      return UIImage(named: "яйцо_орла")!
    case (.Eagle, .OneCrack):
      return UIImage(named: "яйцо_орла_треснувшее_слабо")!
    case (.Eagle, .ThreeCracks):
      return UIImage(named: "яйцо_орла_треснувшее_сильно")!
    case (.Owl, .New):
      return UIImage(named: "яйцо_совы")!
    case (.Owl, .OneCrack):
      return UIImage(named: "яйцо_совы_треснувшее_слабо")!
    case (.Owl, .ThreeCracks):
      return UIImage(named: "яйцо_совы_треснувшее_сильно")!
    case (.Dragon, .New):
      return UIImage(named: "яйцо_дракона")!
    case (.Dragon, .OneCrack):
      return UIImage(named: "яйцо_дракона_треснувшее_слабо")!
    case (.Dragon, .ThreeCracks):
      return UIImage(named: "яйцо_дракона_треснувшее_сильно")!
    }
  }
  
  // MARK: - Init
  init(UID: String, type: EggType, taskUID: String, position: Int, created: Date) {
    self.UID = UID
    self.type = type
    self.taskUID = taskUID
    self.position = position
    self.created = created
  }
  
  init?(eggCoreData: EggCoreData) {
    guard let type = EggType(rawValue: eggCoreData.type) else { return nil }
    self.UID = eggCoreData.uid
    self.created = eggCoreData.created
    self.taskUID = eggCoreData.taskUID
    self.type = type
    self.position = Int(eggCoreData.position)
  }
  
  // MARK: - Equatable
  static func == (lhs: Egg, rhs: Egg) -> Bool {
    return lhs.identity == rhs.identity
  }
  
  // MARK: - Hashable
  func hash(into hasher: inout Hasher) {
      hasher.combine(taskUID)
  }
}
