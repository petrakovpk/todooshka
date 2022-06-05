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
  
  // types
  var typesUID: [String]
  
  // price and currency
  let price: Int
  let currency: Currency
  
  // isBought
  var isBought: Bool
  
  // MARK: - Computed properties
  var identity: String {
    return UID
  }
  
  // MARK: - Init
  init(UID: String, name: String, description: String, clade: BirdClade, style: BirdStyle, price: Int, currency: Currency, isBought: Bool, typesUID: [String]) {
    self.UID = UID
    self.currency = currency
    self.description = description
    self.isBought = isBought
    self.name = name
    self.price = price
    self.clade = clade
    self.style = style
    self.typesUID = typesUID
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
    self.typesUID = birdCoreData.typesUID
  }
  
  // MARK: - Equatable
  static func == (lhs: Bird, rhs: Bird) -> Bool {
    return lhs.identity == rhs.identity && lhs.isBought == rhs.isBought
  }
  
  // MARK: - image
  func getImageForState(state: BirdState) -> UIImage? {
    return UIImage(named: clade.stringForImage + "_" + style.stringForImage + "_" + state.stringForImage)
  }
}

// MARK: - Static Properties
extension Bird {
  
  // Chiken
  struct Chiken {
    static let Simple: Bird = Bird(UID: "ChikenSimple", name: "Курица", description: "Простая", clade: .Chiken, style: .Simple, price: 5, currency: .Feather, isBought: true, typesUID: [TaskType.Standart.Empty.UID])
    static let Student: Bird = Bird(UID: "ChikenStudent", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Student, price: 0, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Student.UID])
    static let Business: Bird = Bird(UID: "ChikenBusiness", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Business, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Business.UID])
    static let Cook: Bird = Bird(UID: "ChikenCook", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Cook, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Cook.UID])
    static let Fashion: Bird = Bird(UID: "ChikenFashion", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Fashion, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Fashion.UID])
    static let Kid: Bird = Bird(UID: "ChikenKid", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Kid, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Kid.UID])
    static let Sport: Bird = Bird(UID: "ChikenSport", name: "Ряба", description: "Так себе птица", clade: .Chiken, style: .Sport, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Sport.UID])
  }
  
  // Ostrich
  struct Ostrich {
    static let Simple: Bird = Bird(UID: "OstrichSimple", name: "Курица", description: "Простая", clade: .Ostrich, style: .Simple, price: 5, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Empty.UID])
    static let Student: Bird = Bird(UID: "OstrichStudent", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Student, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Student.UID])
    static let Business: Bird = Bird(UID: "OstrichBusiness", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Business, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Business.UID])
    static let Cook: Bird = Bird(UID: "OstrichCook", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Cook, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Cook.UID])
    static let Fashion: Bird = Bird(UID: "OstrichFashion", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Fashion, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Fashion.UID])
    static let Kid: Bird = Bird(UID: "OstrichKid", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Kid, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Kid.UID])
    static let Sport: Bird = Bird(UID: "OstrichSport", name: "Ряба", description: "Так себе птица", clade: .Ostrich, style: .Sport, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Sport.UID])
  }
  
  // Owl
  struct Owl {
    static let Simple: Bird = Bird(UID: "OwlSimple", name: "Курица", description: "Простая", clade: .Owl, style: .Simple, price: 5, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Empty.UID])
    static let Student: Bird = Bird(UID: "OwlStudent", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Student, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Student.UID])
    static let Business: Bird = Bird(UID: "OwlBusiness", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Business, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Business.UID])
    static let Cook: Bird = Bird(UID: "OwlCook", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Cook, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Cook.UID])
    static let Fashion: Bird = Bird(UID: "OwlFashion", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Fashion, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Fashion.UID])
    static let Kid: Bird = Bird(UID: "OwlKid", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Kid, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Kid.UID])
    static let Sport: Bird = Bird(UID: "OwlSport", name: "Ряба", description: "Так себе птица", clade: .Owl, style: .Sport, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Sport.UID])
  }
  
  // Parrot
  struct Parrot {
    static let Simple: Bird = Bird(UID: "ParrotSimple", name: "Курица", description: "Простая", clade: .Parrot, style: .Simple, price: 5, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Empty.UID])
    static let Student: Bird = Bird(UID: "ParrotStudent", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Student, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Student.UID])
    static let Business: Bird = Bird(UID: "ParrotBusiness", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Business, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Business.UID])
    static let Cook: Bird = Bird(UID: "ParrotCook", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Cook, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Cook.UID])
    static let Fashion: Bird = Bird(UID: "ParrotFashion", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Fashion, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Fashion.UID])
    static let Kid: Bird = Bird(UID: "ParrotKid", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Kid, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Kid.UID])
    static let Sport: Bird = Bird(UID: "ParrotSport", name: "Ряба", description: "Так себе птица", clade: .Parrot, style: .Sport, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Sport.UID])
  }
  
  // Penguin
  struct Penguin {
    static let Simple: Bird = Bird(UID: "PenguinSimple", name: "Курица", description: "Простая", clade: .Penguin, style: .Simple, price: 5, currency: .Feather, isBought: true, typesUID: [TaskType.Standart.Empty.UID])
    static let Student: Bird = Bird(UID: "PenguinStudent", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Student, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Student.UID])
    static let Business: Bird = Bird(UID: "PenguinBusiness", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Business, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Business.UID])
    static let Cook: Bird = Bird(UID: "PenguinCook", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Cook, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Cook.UID])
    static let Fashion: Bird = Bird(UID: "PenguinFashion", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Fashion, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Fashion.UID])
    static let Kid: Bird = Bird(UID: "PenguinKid", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Kid, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Kid.UID])
    static let Sport: Bird = Bird(UID: "PenguinSport", name: "Ряба", description: "Так себе птица", clade: .Penguin, style: .Sport, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Sport.UID])
  }
  
  // Eagle
  struct Eagle {
    static let Simple: Bird = Bird(UID: "EagleSimple", name: "Курица", description: "Простая", clade: .Eagle, style: .Simple, price: 5, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Empty.UID])
    static let Student: Bird = Bird(UID: "EagleStudent", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Student, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Student.UID])
    static let Business: Bird = Bird(UID: "EagleBusiness", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Business, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Business.UID])
    static let Cook: Bird = Bird(UID: "EagleCook", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Cook, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Cook.UID])
    static let Fashion: Bird = Bird(UID: "EagleFashion", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Fashion, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Fashion.UID])
    static let Kid: Bird = Bird(UID: "EagleKid", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Kid, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Kid.UID])
    static let Sport: Bird = Bird(UID: "EagleSport", name: "Ряба", description: "Так себе птица", clade: .Eagle, style: .Sport, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Sport.UID])
  }
  
  // Dragon
  struct Dragon {
    static let Simple: Bird = Bird(UID: "DragonSimple", name: "Курица", description: "Простая", clade: .Dragon, style: .Simple, price: 2, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Empty.UID])
    static let Student: Bird = Bird(UID: "DragonStudent", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Student, price: 3, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Student.UID])
    static let Business: Bird = Bird(UID: "DragonBusiness", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Business, price: 4, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Business.UID])
    static let Cook: Bird = Bird(UID: "DragonCook", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Cook, price: 5, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Cook.UID])
    static let Fashion: Bird = Bird(UID: "DragonFashion", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Fashion, price: 6, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Fashion.UID])
    static let Kid: Bird = Bird(UID: "DragonKid", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Kid, price: 7, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Kid.UID])
    static let Sport: Bird = Bird(UID: "DragonSport", name: "Ряба", description: "Так себе птица", clade: .Dragon, style: .Sport, price: 8, currency: .Feather, isBought: false, typesUID: [TaskType.Standart.Sport.UID])
  }
}
