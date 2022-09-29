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
  let description: String
  let name: String
  let price: Int
  let style: Style
  let UID: String
  
  var userUID: String? = Auth.auth().currentUser?.uid { didSet { lastModified = Date().timeIntervalSince1970} }
  var isBought: Bool = false { didSet { lastModified = Date().timeIntervalSince1970} }
  var lastModified: Double = Date().timeIntervalSince1970
  
  var eggImage: UIImage? {
    UIImage(named: "яйцо_" + clade.rawValue + "_" + "без_трещин")
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

// MARK: - Static Properties
extension Bird {
  
  // Chiken
  struct Chiken {
    static let Simple: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "ChikenSimple", isBought: true, lastModified: 0)
    static let Student: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 4, style: .Student,UID: "ChikenStudent", isBought: false, lastModified: 0)
    static let Business: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 7, style: .Business,UID: "ChikenBusiness", isBought: false, lastModified: 0)
    static let Cook: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 8, style: .Cook,UID: "ChikenCook", isBought: false, lastModified: 0)
    static let Fashion: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 9, style: .Fashion,UID: "ChikenFashion", isBought: false, lastModified: 0)
    static let Kid: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 10, style: .Kid,UID: "ChikenKid", isBought: false, lastModified: 0)
    static let Sport: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 15, style: .Sport,UID: "ChikenSport", isBought: false, lastModified: 0)
  }

  // Ostrich
  struct Ostrich {
    static let Simple: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "OstrichSimple", isBought: true)
    static let Student: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 4, style: .Student,UID: "OstrichStudent", isBought: false, lastModified: 0)
    static let Business: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 7, style: .Business,UID: "OstrichBusiness", isBought: false, lastModified: 0)
    static let Cook: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 8, style: .Cook,UID: "OstrichCook", isBought: false, lastModified: 0)
    static let Fashion: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 9, style: .Fashion,UID: "OstrichFashion", isBought: false, lastModified: 0)
    static let Kid: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 10, style: .Kid,UID: "OstrichKid", isBought: false, lastModified: 0)
    static let Sport: Bird = Bird(clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 15, style: .Sport,UID: "OstrichSport", isBought: false, lastModified: 0)
  }

  // Owl
  struct Owl {
    static let Simple: Bird = Bird( clade: .Owl, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "OwlSimple", isBought: true)
    static let Student: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 4, style: .Student,UID: "OwlStudent", isBought: false, lastModified: 0)
    static let Business: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 7, style: .Business,UID: "OwlBusiness", isBought: false, lastModified: 0)
    static let Cook: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 8, style: .Cook,UID: "OwlCook", isBought: false, lastModified: 0)
    static let Fashion: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 9, style: .Fashion,UID: "OwlFashion", isBought: false, lastModified: 0)
    static let Kid: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 10, style: .Kid,UID: "OwlKid", isBought: false, lastModified: 0)
    static let Sport: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 15, style: .Sport,UID: "OwlSport", isBought: false, lastModified: 0)
  }

  // Parrot
  struct Parrot {
    static let Simple: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "ParrotSimple", isBought: true)
    static let Student: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 4, style: .Student,UID: "ParrotStudent", isBought: false, lastModified: 0)
    static let Business: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 7, style: .Business,UID: "ParrotBusiness", isBought: false, lastModified: 0)
    static let Cook: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 8, style: .Cook,UID: "ParrotCook", isBought: false, lastModified: 0)
    static let Fashion: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 9, style: .Fashion,UID: "ParrotFashion", isBought: false, lastModified: 0)
    static let Kid: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 10, style: .Kid,UID: "ParrotKid", isBought: false, lastModified: 0)
    static let Sport: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 15, style: .Sport,UID: "ParrotSport", isBought: false, lastModified: 0)
  }

  // Penguin
  struct Penguin {
    static let Simple: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "PenguinSimple", isBought: true)
    static let Student: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 4, style: .Student,UID: "PenguinStudent", isBought: false, lastModified: 0)
    static let Business: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 7, style: .Business,UID: "PenguinBusiness", isBought: false, lastModified: 0)
    static let Cook: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 8, style: .Cook,UID: "PenguinCook", isBought: false, lastModified: 0)
    static let Fashion: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 9, style: .Fashion,UID: "PenguinFashion", isBought: false, lastModified: 0)
    static let Kid: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 10, style: .Kid,UID: "PenguinKid", isBought: false, lastModified: 0)
    static let Sport: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 15, style: .Sport,UID: "PenguinSport", isBought: false, lastModified: 0)
  }

  // Eagle
  struct Eagle {
    static let Simple: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "EagleSimple", isBought: true)
    static let Student: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 4, style: .Student,UID: "EagleStudent", isBought: false, lastModified: 0)
    static let Business: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 7, style: .Business,UID: "EagleBusiness", isBought: false, lastModified: 0)
    static let Cook: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 8, style: .Cook,UID: "EagleCook", isBought: false, lastModified: 0)
    static let Fashion: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 9, style: .Fashion,UID: "EagleFashion", isBought: false, lastModified: 0)
    static let Kid: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 10, style: .Kid,UID: "EagleKid", isBought: false, lastModified: 0)
    static let Sport: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 15, style: .Sport,UID: "EagleSport", isBought: false, lastModified: 0)
  }

  // Dragon
  struct Dragon {
    static let Simple: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "DragonSimple", isBought: true)
    static let Student: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 4, style: .Student,UID: "DragonStudent", isBought: false, lastModified: 0)
    static let Business: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 7, style: .Business,UID: "DragonBusiness", isBought: false, lastModified: 0)
    static let Cook: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 8, style: .Cook,UID: "DragonCook", isBought: false, lastModified: 0)
    static let Fashion: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 9, style: .Fashion,UID: "DragonFashion", isBought: false, lastModified: 0)
    static let Kid: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 10, style: .Kid,UID: "DragonKid", isBought: false, lastModified: 0)
    static let Sport: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 15, style: .Sport,UID: "DragonSport", isBought: false, lastModified: 0)
  }
}


// MARK: - Firebase
extension Bird {
  typealias D = DataSnapshot
  
  var data: [AnyHashable: Any] {
    [
      "isBought": isBought,
      "lastModified": lastModified
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
  
  init(entity: T) {
    UID = entity.value(forKey: "uid") as! String
    clade = Clade(rawValue: entity.value(forKey: "cladeRawValue") as! String) ?? Clade.Chiken
    currency = Currency(rawValue: entity.value(forKey: "currencyRawValue") as! String) ?? Currency.Feather
    description = entity.value(forKey: "desc") as! String
    name = entity.value(forKey: "name") as! String
    price = entity.value(forKey: "price") as! Int
    style = Style(rawValue: entity.value(forKey: "styleRawValue") as! String) ?? Style.Simple
    isBought = entity.value(forKey: "isBought") as! Bool
    userUID = entity.value(forKey: "userUID") as? String
    lastModified = entity.value(forKey: "lastModified") as! Double
  }
  
  func update(_ entity: T) {
    entity.setValue(UID, forKey: "uid")
    entity.setValue(clade.rawValue, forKey: "cladeRawValue")
    entity.setValue(currency.rawValue, forKey: "currencyRawValue")
    entity.setValue(description, forKey: "desc")
    entity.setValue(name, forKey: "name")
    entity.setValue(price, forKey: "price")
    entity.setValue(style.rawValue, forKey: "styleRawValue")
    entity.setValue(isBought, forKey: "isBought")
    entity.setValue(userUID, forKey: "userUID")
    entity.setValue(lastModified, forKey: "lastModified")

    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
