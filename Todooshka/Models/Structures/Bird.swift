//
//  Bird.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import CoreData
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
  
  var isBought: Bool
  
  var eggImage: UIImage? {
    UIImage(named: "яйцо_" + clade.rawValue + "_" + "без_трещин")
  }
  
  // MARK: - Equatable
  static func == (lhs: Bird, rhs: Bird) -> Bool {
    lhs.identity == rhs.identity
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
    static let Simple: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "ChikenSimple", isBought: true)
    static let Student: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Student,UID: "ChikenStudent", isBought: false)
    static let Business: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Business,UID: "ChikenBusiness", isBought: false)
    static let Cook: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Cook,UID: "ChikenCook", isBought: false)
    static let Fashion: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Fashion,UID: "ChikenFashion", isBought: false)
    static let Kid: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Kid,UID: "ChikenKid", isBought: false)
    static let Sport: Bird = Bird( clade: .Chiken, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Sport,UID: "ChikenSport", isBought: false)
  }

  // Ostrich
  struct Ostrich {
    static let Simple: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "OstrichSimple", isBought: false)
    static let Student: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Student,UID: "OstrichStudent", isBought: false)
    static let Business: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Business,UID: "OstrichBusiness", isBought: false)
    static let Cook: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Cook,UID: "OstrichCook", isBought: false)
    static let Fashion: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Fashion,UID: "OstrichFashion", isBought: false)
    static let Kid: Bird = Bird( clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Kid,UID: "OstrichKid", isBought: false)
    static let Sport: Bird = Bird(clade: .Ostrich, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Sport,UID: "OstrichSport", isBought: false)
  }

  // Owl
  struct Owl {
    static let Simple: Bird = Bird( clade: .Owl, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "OwlSimple", isBought: false)
    static let Student: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Student,UID: "OwlStudent", isBought: false)
    static let Business: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Business,UID: "OwlBusiness", isBought: false)
    static let Cook: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Cook,UID: "OwlCook", isBought: false)
    static let Fashion: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Fashion,UID: "OwlFashion", isBought: false)
    static let Kid: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Kid,UID: "OwlKid", isBought: false)
    static let Sport: Bird = Bird( clade: .Owl, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Sport,UID: "OwlSport", isBought: false)
  }

  // Parrot
  struct Parrot {
    static let Simple: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "ParrotSimple", isBought: false)
    static let Student: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Student,UID: "ParrotStudent", isBought: false)
    static let Business: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Business,UID: "ParrotBusiness", isBought: false)
    static let Cook: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Cook,UID: "ParrotCook", isBought: false)
    static let Fashion: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Fashion,UID: "ParrotFashion", isBought: false)
    static let Kid: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Kid,UID: "ParrotKid", isBought: false)
    static let Sport: Bird = Bird( clade: .Parrot, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Sport,UID: "ParrotSport", isBought: false)
  }

  // Penguin
  struct Penguin {
    static let Simple: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "PenguinSimple", isBought: true)
    static let Student: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Student,UID: "PenguinStudent", isBought: false)
    static let Business: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Business,UID: "PenguinBusiness", isBought: false)
    static let Cook: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Cook,UID: "PenguinCook", isBought: false)
    static let Fashion: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Fashion,UID: "PenguinFashion", isBought: false)
    static let Kid: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Kid,UID: "PenguinKid", isBought: false)
    static let Sport: Bird = Bird( clade: .Penguin, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Sport,UID: "PenguinSport", isBought: false)
  }

  // Eagle
  struct Eagle {
    static let Simple: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "EagleSimple", isBought: false)
    static let Student: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Student,UID: "EagleStudent", isBought: false)
    static let Business: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Business,UID: "EagleBusiness", isBought: false)
    static let Cook: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Cook,UID: "EagleCook", isBought: false)
    static let Fashion: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Fashion,UID: "EagleFashion", isBought: false)
    static let Kid: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Kid,UID: "EagleKid", isBought: false)
    static let Sport: Bird = Bird( clade: .Eagle, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Sport,UID: "EagleSport", isBought: false)
  }

  // Dragon
  struct Dragon {
    static let Simple: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Простая", name: "Курица", price: 0, style: .Simple,UID: "DragonSimple", isBought: false)
    static let Student: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Student,UID: "DragonStudent", isBought: false)
    static let Business: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Business,UID: "DragonBusiness", isBought: false)
    static let Cook: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Cook,UID: "DragonCook", isBought: false)
    static let Fashion: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Fashion,UID: "DragonFashion", isBought: false)
    static let Kid: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Kid,UID: "DragonKid", isBought: false)
    static let Sport: Bird = Bird( clade: .Dragon, currency: .Feather, description: "Так себе птица", name: "Ряба", price: 0, style: .Sport,UID: "DragonSport", isBought: false)
  }
}

// MARK: - Persistable
extension Bird: Persistable {
  typealias T = NSManagedObject
  
  static var entityName: String {
    return "Bird"
  }
  
  static var primaryAttributeName: String {
    return "uid"
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
    
    do {
      try entity.managedObjectContext?.save()
    } catch let error {
      print(error)
    }
  }
}
