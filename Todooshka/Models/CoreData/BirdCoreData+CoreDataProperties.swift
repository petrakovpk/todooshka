//
//  BirdCoreData+CoreDataProperties.swift
//  
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//
//
//
// import Foundation
// import CoreData
//
//
// extension BirdCoreData {
//
//  @nonobjc public class func fetchRequest() -> NSFetchRequest<BirdCoreData> {
//      return NSFetchRequest<BirdCoreData>(entityName: "BirdCoreData")
//  }
//
//  @NSManaged public var uid: String
//  @NSManaged public var isBought: Bool
//  @NSManaged public var price: Int16
//  @NSManaged public var clade: String
//  @NSManaged public var style: String
//  @NSManaged public var name: String
//  @NSManaged public var desc: String
//  @NSManaged public var currency: String
//  @NSManaged public var typesUID: [String]
//  
//  // init from bird
//  convenience init(context: NSManagedObjectContext, bird: Bird) {
//    self.init(context: context)
//    self.uid = bird.UID
//    self.isBought = bird.isBought
//    self.price = Int16(bird.price)
//    self.clade = bird.clade.rawValue
//    self.style = bird.style.rawValue
//    self.name = bird.name
//    self.desc = bird.description
//    self.currency = bird.currency.rawValue
//    self.typesUID = bird.typesUID
//  }
//  
//  func loadFromBird(bird: Bird) {
//    self.uid = bird.UID
//    self.isBought = bird.isBought
//    self.price = Int16(bird.price)
//    self.clade = bird.clade.rawValue
//    self.style = bird.style.rawValue
//    self.name = bird.name
//    self.desc = bird.description
//    self.currency = bird.currency.rawValue
//    self.typesUID = bird.typesUID
//  }
// }
