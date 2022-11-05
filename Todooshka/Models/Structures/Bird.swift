//
//  Bird.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import CoreData
import Firebase
import Differentiator

struct Bird: IdentifiableType, Equatable {

  // MARK: - IdentifiableType
  var identity: String { UID }

  // MARK: - Properties
  let clade: Clade
  let currency: Currency
  let price: Int
  let style: BirdStyle
  let UID: String
  var userUID: String?
  var isBought: Bool = false { willSet { lastModified = Date()} }
  var lastModified: Date = Date()

  var eggImage: UIImage? {
    UIImage(named: "яйцо_" + clade.rawValue + "_" + "без_трещин")
  }

  var name: String {
    switch style {
    case .simple:
      return "Мультизадачный"
    case .business:
      return "Работяга"
    case .student:
      return "Студент"
    case .cook:
      return "Повар"
    case .fashion:
      return "Модник"
    case .kid:
      return "Малыш"
    case .sport:
      return "Спортсмен"
    }
  }

  // MARK: - Equatable
  static func == (lhs: Bird, rhs: Bird) -> Bool {
    lhs.identity == rhs.identity
    && lhs.isBought == rhs.isBought
    && lhs.userUID == rhs.userUID
    && lhs.lastModified == rhs.lastModified
  }

  // MARK: - image
  func getImageForState(state: BirdState) -> UIImage? {
    UIImage(named: clade.rawValue + "_" + style.imageName + "_" + state.rawValue)
  }
}

// MARK: - Firebase
extension Bird {
  typealias D = DataSnapshot

  var data: [AnyHashable: Any] {
    [
      "isBought": isBought,
      "lastModified": lastModified.timeIntervalSince1970
    ]
  }
}

// MARK: - Persistable
extension Bird: Persistable {
  typealias T = NSManagedObject

  static var entityName: String {
    "Bird"
  }

  static var primaryAttributeName: String {
    "uid"
  }

  init?(entity: T) {
    guard
      let uid = entity.value(forKey: "uid") as? String,
      let cladeRawValue = entity.value(forKey: "cladeRawValue") as? String,
      let clade = Clade(rawValue: cladeRawValue),
      let currencyRawValue = entity.value(forKey: "currencyRawValue") as? String,
      let currency = Currency(rawValue: currencyRawValue),
      let price = entity.value(forKey: "price") as? Int,
      let styleRawValue = entity.value(forKey: "styleRawValue") as? String,
      let birdStyle = BirdStyle(rawValue: styleRawValue),
      let isBought = entity.value(forKey: "isBought") as? Bool,
      let lastModified = entity.value(forKey: "lastModified") as? Date
    else { return nil  }

    self.UID = uid
    self.clade = clade
    self.currency = currency
    self.price = price
    self.style = birdStyle
    self.isBought = isBought
    self.userUID = entity.value(forKey: "userUID") as? String
    self.lastModified = lastModified
  }

  func update(_ entity: T) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(clade.rawValue, forKey: "cladeRawValue")
    entity.setValue(currency.rawValue, forKey: "currencyRawValue")
    entity.setValue(price, forKey: "price")
    entity.setValue(style.rawValue, forKey: "styleRawValue")
    entity.setValue(isBought, forKey: "isBought")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(lastModified, forKey: "lastModified")
  }

  func save(_ entity: T) {
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}

// MARK: - Static Properties
extension Bird {

  // Chiken
  struct Chiken {
    static let Simple: Bird = Bird( clade: .chiken, currency: .feather, price: 0, style: .simple, UID: "ChikenSimple", isBought: true, lastModified: Date(timeIntervalSince1970: 0))
    static let Student: Bird = Bird( clade: .chiken, currency: .feather, price: 4, style: .student, UID: "ChikenStudent", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Business: Bird = Bird( clade: .chiken, currency: .feather, price: 8, style: .business, UID: "ChikenBusiness", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Cook: Bird = Bird( clade: .chiken, currency: .feather, price: 12, style: .cook, UID: "ChikenCook", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Fashion: Bird = Bird( clade: .chiken, currency: .feather, price: 18, style: .fashion, UID: "ChikenFashion", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Kid: Bird = Bird( clade: .chiken, currency: .diamond, price: 15, style: .kid, UID: "ChikenKid", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Sport: Bird = Bird( clade: .chiken, currency: .diamond, price: 19, style: .sport, UID: "ChikenSport", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
  }

  // Ostrich
  struct Ostrich {
    static let Simple: Bird = Bird( clade: .ostrich, currency: .feather, price: 0, style: .simple, UID: "OstrichSimple", isBought: true, lastModified: Date(timeIntervalSince1970: 0))
    static let Student: Bird = Bird( clade: .ostrich, currency: .feather, price: 5, style: .student, UID: "OstrichStudent", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Business: Bird = Bird( clade: .ostrich, currency: .feather, price: 9, style: .business, UID: "OstrichBusiness", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Cook: Bird = Bird( clade: .ostrich, currency: .feather, price: 13, style: .cook, UID: "OstrichCook", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Fashion: Bird = Bird( clade: .ostrich, currency: .feather, price: 19, style: .fashion, UID: "OstrichFashion", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Kid: Bird = Bird( clade: .ostrich, currency: .diamond, price: 17, style: .kid, UID: "OstrichKid", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Sport: Bird = Bird(clade: .ostrich, currency: .diamond, price: 21, style: .sport, UID: "OstrichSport", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
  }

  // Owl
  struct Owl {
    static let Simple: Bird = Bird( clade: .owl, currency: .feather, price: 0, style: .simple, UID: "OwlSimple", isBought: true, lastModified: Date(timeIntervalSince1970: 0))
    static let Student: Bird = Bird( clade: .owl, currency: .feather, price: 6, style: .student, UID: "OwlStudent", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Business: Bird = Bird( clade: .owl, currency: .feather, price: 10, style: .business, UID: "OwlBusiness", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Cook: Bird = Bird( clade: .owl, currency: .feather, price: 14, style: .cook, UID: "OwlCook", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Fashion: Bird = Bird( clade: .owl, currency: .feather, price: 20, style: .fashion, UID: "OwlFashion", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Kid: Bird = Bird( clade: .owl, currency: .diamond, price: 19, style: .kid, UID: "OwlKid", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Sport: Bird = Bird( clade: .owl, currency: .diamond, price: 23, style: .sport, UID: "OwlSport", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
  }

  // Parrot
  struct Parrot {
    static let Simple: Bird = Bird( clade: .parrot, currency: .feather, price: 0, style: .simple, UID: "ParrotSimple", isBought: true, lastModified: Date(timeIntervalSince1970: 0))
    static let Student: Bird = Bird( clade: .parrot, currency: .feather, price: 7, style: .student, UID: "ParrotStudent", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Business: Bird = Bird( clade: .parrot, currency: .feather, price: 11, style: .business, UID: "ParrotBusiness", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Cook: Bird = Bird( clade: .parrot, currency: .feather, price: 15, style: .cook, UID: "ParrotCook", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Fashion: Bird = Bird( clade: .parrot, currency: .feather, price: 21, style: .fashion, UID: "ParrotFashion", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Kid: Bird = Bird( clade: .parrot, currency: .diamond, price: 21, style: .kid, UID: "ParrotKid", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Sport: Bird = Bird( clade: .parrot, currency: .diamond, price: 25, style: .sport, UID: "ParrotSport", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
  }

  // Penguin
  struct Penguin {
    static let Simple: Bird = Bird( clade: .penguin, currency: .feather, price: 0, style: .simple, UID: "PenguinSimple", isBought: true, lastModified: Date(timeIntervalSince1970: 0))
    static let Student: Bird = Bird( clade: .penguin, currency: .feather, price: 8, style: .student, UID: "PenguinStudent", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Business: Bird = Bird( clade: .penguin, currency: .feather, price: 12, style: .business, UID: "PenguinBusiness", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Cook: Bird = Bird( clade: .penguin, currency: .feather, price: 16, style: .cook, UID: "PenguinCook", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Fashion: Bird = Bird( clade: .penguin, currency: .feather, price: 20, style: .fashion, UID: "PenguinFashion", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Kid: Bird = Bird( clade: .penguin, currency: .diamond, price: 23, style: .kid, UID: "PenguinKid", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Sport: Bird = Bird( clade: .penguin, currency: .diamond, price: 27, style: .sport, UID: "PenguinSport", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
  }

  // Eagle
  struct Eagle {
    static let Simple: Bird = Bird( clade: .eagle, currency: .feather, price: 0, style: .simple, UID: "EagleSimple", isBought: true, lastModified: Date(timeIntervalSince1970: 0))
    static let Student: Bird = Bird( clade: .eagle, currency: .feather, price: 9, style: .student, UID: "EagleStudent", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Business: Bird = Bird( clade: .eagle, currency: .feather, price: 13, style: .business, UID: "EagleBusiness", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Cook: Bird = Bird( clade: .eagle, currency: .feather, price: 17, style: .cook, UID: "EagleCook", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Fashion: Bird = Bird( clade: .eagle, currency: .feather, price: 23, style: .fashion, UID: "EagleFashion", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Kid: Bird = Bird( clade: .eagle, currency: .diamond, price: 25, style: .kid, UID: "EagleKid", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Sport: Bird = Bird( clade: .eagle, currency: .diamond, price: 29, style: .sport, UID: "EagleSport", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
  }

  // Dragon
  struct Dragon {
    static let Simple: Bird = Bird(clade: .dragon, currency: .feather, price: 0, style: .simple, UID: "DragonSimple", isBought: true, lastModified: Date(timeIntervalSince1970: 0))
    static let Student: Bird = Bird( clade: .dragon, currency: .diamond, price: 17, style: .student, UID: "DragonStudent", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Business: Bird = Bird( clade: .dragon, currency: .diamond, price: 21, style: .business, UID: "DragonBusiness", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Cook: Bird = Bird( clade: .dragon, currency: .diamond, price: 23, style: .cook, UID: "DragonCook", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Fashion: Bird = Bird( clade: .dragon, currency: .diamond, price: 25, style: .fashion, UID: "DragonFashion", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Kid: Bird = Bird( clade: .dragon, currency: .diamond, price: 27, style: .kid, UID: "DragonKid", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
    static let Sport: Bird = Bird( clade: .dragon, currency: .diamond, price: 31, style: .sport, UID: "DragonSport", isBought: false, lastModified: Date(timeIntervalSince1970: 0))
  }
}
