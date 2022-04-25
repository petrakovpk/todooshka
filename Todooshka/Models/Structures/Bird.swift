//
//  Bird.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import Differentiator

struct Bird: IdentifiableType, Equatable {
  
  // MARK: - Properties
  let UID: String
  
  // name and description
  let name: String
  let description: String
  
  // clade and style
  let clade: BirdClade
  let style: BirdStyle
  
  // price and currency
  let price: Int
  let currency: Currency
  
  // isBought
  var isBought: Bool
  
  // MARK: - Computed properties
  var identity: String {
    return UID
  }
  
  var image: UIImage? {
    switch (clade, style) {
      
      // Chiken
    case (.Chiken, .Simple):
      return UIImage(named: "курица_статика_обычный")
    case (.Chiken, .Student):
      return UIImage(named: "курица_статика_студент")
    case (.Chiken, .Business):
      return UIImage(named: "курица_статика_деловой")
    case (.Chiken, .Cook):
      return UIImage(named: "курица_статика_повар")
    case (.Chiken, .Fashion):
      return UIImage(named: "курица_статика_модный")
    case (.Chiken, .Sport):
      return UIImage(named: "курица_статика_спортивный")
    case (.Chiken, .Kid):
      return UIImage(named: "курица_статика_ребенок")
      
      // Penguin
    case (.Penguin, .Simple):
      return UIImage(named: "пингвин_статика_обычный")
    case (.Penguin, .Student):
      return UIImage(named: "пингвин_статика_студент")
    case (.Penguin, .Business):
      return UIImage(named: "пингвин_статика_деловой")
    case (.Penguin, .Cook):
      return UIImage(named: "пингвин_статика_повар")
    case (.Penguin, .Fashion):
      return UIImage(named: "пингвин_статика_модный")
    case (.Penguin, .Sport):
      return UIImage(named: "пингвин_статика_спортивный")
    case (.Penguin, .Kid):
      return UIImage(named: "пингвин_статика_ребенок")
      
      // Ostrich
    case (.Ostrich, .Simple):
      return UIImage(named: "страус_статика_обычный")
    case (.Ostrich, .Student):
      return UIImage(named: "страус_статика_студент")
    case (.Ostrich, .Business):
      return UIImage(named: "страус_статика_деловой")
    case (.Ostrich, .Cook):
      return UIImage(named: "страус_статика_повар")
    case (.Ostrich, .Fashion):
      return UIImage(named: "страус_статика_модный")
    case (.Ostrich, .Sport):
      return UIImage(named: "страус_статика_спортивный")
    case (.Ostrich, .Kid):
      return UIImage(named: "страус_статика_ребенок")
      
      // Parrot
    case (.Parrot, .Simple):
      return UIImage(named: "попугай_статика_обычный")
    case (.Parrot, .Student):
      return UIImage(named: "попугай_статика_студент")
    case (.Parrot, .Business):
      return UIImage(named: "попугай_статика_деловой")
    case (.Parrot, .Cook):
      return UIImage(named: "попугай_статика_повар")
    case (.Parrot, .Fashion):
      return UIImage(named: "попугай_статика_модный")
    case (.Parrot, .Sport):
      return UIImage(named: "попугай_статика_спортивный")
    case (.Parrot, .Kid):
      return UIImage(named: "попугай_статика_ребенок")
      
      // Eagle
    case (.Eagle, .Simple):
      return UIImage(named: "орел_статика_обычный")
    case (.Eagle, .Student):
      return UIImage(named: "орел_статика_студент")
    case (.Eagle, .Business):
      return UIImage(named: "орел_статика_деловой")
    case (.Eagle, .Cook):
      return UIImage(named: "орел_статика_повар")
    case (.Eagle, .Fashion):
      return UIImage(named: "орел_статика_модный")
    case (.Eagle, .Sport):
      return UIImage(named: "орел_статика_спортивный")
    case (.Eagle, .Kid):
      return UIImage(named: "орел_статика_ребенок")
      
      // Owl
    case (.Owl, .Simple):
      return UIImage(named: "сова_статика_обычный")
    case (.Owl, .Student):
      return UIImage(named: "сова_статика_студент")
    case (.Owl, .Business):
      return UIImage(named: "сова_статика_деловой")
    case (.Owl, .Cook):
      return UIImage(named: "сова_статика_повар")
    case (.Owl, .Fashion):
      return UIImage(named: "сова_статика_модный")
    case (.Owl, .Sport):
      return UIImage(named: "сова_статика_спортивный")
    case (.Owl, .Kid):
      return UIImage(named: "сова_статика_ребенок")
      
      // Dragon
    case (.Dragon, .Simple):
      return UIImage(named: "дракон_статика_обычный")
    case (.Dragon, .Student):
      return UIImage(named: "дракон_статика_студент")
    case (.Dragon, .Business):
      return UIImage(named: "дракон_статика_деловой")
    case (.Dragon, .Cook):
      return UIImage(named: "дракон_статика_повар")
    case (.Dragon, .Fashion):
      return UIImage(named: "дракон_статика_модный")
    case (.Dragon, .Sport):
      return UIImage(named: "дракон_статика_спортивный")
    case (.Dragon, .Kid):
      return UIImage(named: "дракон_статика_ребенок")
      
      // default
    default:
      return nil
    }
  }
  
  // MARK: - Init
  init(UID: String, name: String, description: String, clade: BirdClade, style: BirdStyle, price: Int, currency: Currency, isBought: Bool) {
    self.UID = UID
    self.currency = currency
    self.description = description
    self.isBought = isBought
    self.name = name
    self.price = price
    self.clade = clade
    self.style = style
  }
  
  init?(birdCoreData: BirdCoreData) {
    guard
      let currency = Currency(rawValue: birdCoreData.currency),
      let clade = BirdClade(rawValue: birdCoreData.clade),
      let style = BirdStyle(rawValue: birdCoreData.style)
    else { return nil }
    
    self.currency = currency
    self.clade = clade
    self.style = style
    self.UID = birdCoreData.uid
    self.description = birdCoreData.desc
    self.isBought = birdCoreData.isBought
    self.name = birdCoreData.name
    self.price = Int(birdCoreData.price)
  }
  
  // MARK: - Equatable
  static func == (lhs: Bird, rhs: Bird) -> Bool {
    return lhs.identity == rhs.identity
  }
}


// MARK: - Static Properties
extension Bird {
  
  // Chiken
  struct Chiken {
    
    static let Simple: Bird = Bird(UID: "ChikenSimple", name: "Курица", description: "Простая", clade: .Chiken, style: .Simple, price: 5, currency: .Feather, isBought: true)
    
    static let Student: Bird = Bird( UID: "ChikenStudent", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Student, price: 2, currency: .Feather, isBought: false)
    
    static let Business: Bird = Bird( UID: "ChikenBusiness", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Business, price: 2, currency: .Feather, isBought: false)
    
    static let Cook: Bird = Bird( UID: "ChikenCook", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Cook, price: 2, currency: .Feather, isBought: false)
    
    static let Fashion: Bird = Bird( UID: "ChikenFashion", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Fashion, price: 2, currency: .Feather, isBought: false)
    
    static let Kid: Bird = Bird( UID: "ChikenKid", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Kid, price: 2, currency: .Feather, isBought: false)
    
    static let Sport: Bird = Bird( UID: "ChikenSport", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Sport, price: 2, currency: .Feather, isBought: false)
  }
  
  // Ostrich
  struct Ostrich {
    
    static let Simple: Bird = Bird(UID: "OstrichSimple", name: "Курица", description: "Простая", clade: .Ostrich, style: .Simple, price: 5, currency: .Feather, isBought: true)
    
    static let Student: Bird = Bird( UID: "OstrichStudent", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Student, price: 2, currency: .Feather, isBought: false)
    
    static let Business: Bird = Bird( UID: "OstrichBusiness", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Business, price: 2, currency: .Feather, isBought: false)
    
    static let Cook: Bird = Bird( UID: "OstrichCook", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Cook, price: 2, currency: .Feather, isBought: false)
    
    static let Fashion: Bird = Bird( UID: "OstrichFashion", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Fashion, price: 2, currency: .Feather, isBought: false)
    
    static let Kid: Bird = Bird( UID: "OstrichKid", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Kid, price: 2, currency: .Feather, isBought: false)
    
    static let Sport: Bird = Bird( UID: "OstrichSport", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Sport, price: 2, currency: .Feather, isBought: false)
  }
  
  // Owl
  struct Owl {
    
    static let Simple: Bird = Bird(UID: "OwlSimple", name: "Курица", description: "Простая", clade: .Owl, style: .Simple, price: 5, currency: .Feather, isBought: true)
    
    static let Student: Bird = Bird( UID: "OwlStudent", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Student, price: 2, currency: .Feather, isBought: false)
    
    static let Business: Bird = Bird( UID: "OwlBusiness", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Business, price: 2, currency: .Feather, isBought: false)
    
    static let Cook: Bird = Bird( UID: "OwlCook", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Cook, price: 2, currency: .Feather, isBought: false)
    
    static let Fashion: Bird = Bird( UID: "OwlFashion", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Fashion, price: 2, currency: .Feather, isBought: false)
    
    static let Kid: Bird = Bird( UID: "OwlKid", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Kid, price: 2, currency: .Feather, isBought: false)
    
    static let Sport: Bird = Bird( UID: "OwlSport", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Sport, price: 2, currency: .Feather, isBought: false)
  }
  
  // Parrot
  struct Parrot {
    static let Simple: Bird = Bird(UID: "ParrotSimple", name: "Курица", description: "Простая", clade: .Parrot, style: .Simple, price: 5, currency: .Feather, isBought: true)
    
    static let Student: Bird = Bird( UID: "ParrotStudent", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Student, price: 2, currency: .Feather, isBought: false)
    
    static let Business: Bird = Bird( UID: "ParrotBusiness", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Business, price: 2, currency: .Feather, isBought: false)
    
    static let Cook: Bird = Bird( UID: "ParrotCook", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Cook, price: 2, currency: .Feather, isBought: false)
    
    static let Fashion: Bird = Bird( UID: "ParrotFashion", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Fashion, price: 2, currency: .Feather, isBought: false)
    
    static let Kid: Bird = Bird( UID: "ParrotKid", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Kid, price: 2, currency: .Feather, isBought: false)
    
    static let Sport: Bird = Bird( UID: "ParrotSport", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Sport, price: 2, currency: .Feather, isBought: false)
  }
  
  // Penguin
  struct Penguin {
    
    static let Simple: Bird = Bird(UID: "PenguinSimple", name: "Курица", description: "Простая", clade: .Penguin, style: .Simple, price: 5, currency: .Feather, isBought: true)
    
    static let Student: Bird = Bird( UID: "PenguinStudent", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Student, price: 2, currency: .Feather, isBought: false)
    
    static let Business: Bird = Bird( UID: "PenguinBusiness", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Business, price: 2, currency: .Feather, isBought: false)
    
    static let Cook: Bird = Bird( UID: "PenguinCook", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Cook, price: 2, currency: .Feather, isBought: false)
    
    static let Fashion: Bird = Bird( UID: "PenguinFashion", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Fashion, price: 2, currency: .Feather, isBought: false)
    
    static let Kid: Bird = Bird( UID: "PenguinKid", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Kid, price: 2, currency: .Feather, isBought: false)
    
    static let Sport: Bird = Bird( UID: "PenguinSport", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Sport, price: 2, currency: .Feather, isBought: false)
  }
  
  // Eagle
  struct Eagle {
    
    static let Simple: Bird = Bird(UID: "EagleSimple", name: "Курица", description: "Простая", clade: .Eagle, style: .Simple, price: 5, currency: .Feather, isBought: true)
    
    static let Student: Bird = Bird( UID: "EagleStudent", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Student, price: 2, currency: .Feather, isBought: false)
    
    static let Business: Bird = Bird( UID: "EagleBusiness", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Business, price: 2, currency: .Feather, isBought: false)
    
    static let Cook: Bird = Bird( UID: "EagleCook", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Cook, price: 2, currency: .Feather, isBought: false)
    
    static let Fashion: Bird = Bird( UID: "EagleFashion", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Fashion, price: 2, currency: .Feather, isBought: false)
    
    static let Kid: Bird = Bird( UID: "EagleKid", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Kid, price: 2, currency: .Feather, isBought: false)
    
    static let Sport: Bird = Bird( UID: "EagleSport", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Sport, price: 2, currency: .Feather, isBought: false)
  }
  
  // Dragon
  struct Dragon {
    
    static let Simple: Bird = Bird(UID: "DragonSimple", name: "Курица", description: "Простая", clade: .Dragon, style: .Simple, price: 5, currency: .Feather, isBought: true)
    
    static let Student: Bird = Bird( UID: "DragonStudent", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Student, price: 2, currency: .Feather, isBought: false)
    
    static let Business: Bird = Bird( UID: "DragonBusiness", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Business, price: 2, currency: .Feather, isBought: false)
    
    static let Cook: Bird = Bird( UID: "DragonCook", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Cook, price: 2, currency: .Feather, isBought: false)
    
    static let Fashion: Bird = Bird( UID: "DragonFashion", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Fashion, price: 2, currency: .Feather, isBought: false)
    
    static let Kid: Bird = Bird( UID: "DragonKid", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Kid, price: 2, currency: .Feather, isBought: false)
    
    static let Sport: Bird = Bird( UID: "DragonSport", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Sport, price: 2, currency: .Feather, isBought: false)
  }
}
