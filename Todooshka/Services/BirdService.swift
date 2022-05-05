//
//  BirdsService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//

import CoreData
import RxSwift
import RxCocoa

protocol HasBirdService {
  var birdService: BirdService { get }
}

class BirdService {
  
  // MARK: - Core Data Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var managedContext: NSManagedObjectContext {
    return self.appDelegate.persistentContainer.viewContext
  }
  
  // MARK: - Score Properties
  let birds = BehaviorRelay<[Bird]>(value: [])
  let eggs = BehaviorRelay<[Egg]>(value: [])
  
  // MARK: - Init
  init() {
    removeAllEggsCoreData()
    removeAllBirdsCoreData()
    
    // Get Birds from Core Data
    for birdCoreData in getBirdsCoreData() {
      if let bird = Bird(birdCoreData: birdCoreData) {
        self.birds.accept(self.birds.value + [bird])
      }
    }
    
    // Get Eggs from Core Data
    for eggCoreData in getEggsCoreData() {
      if let egg = Egg(eggCoreData: eggCoreData) {
        egg.created < Date().adding(.day, value: -1) ? removeEgg(egg: egg) : self.eggs.accept(self.eggs.value + [egg])
      }
    }

    // Start Observing
    startObserveCoreData()
    
    // If first loading - create standart
    if self.birds.value.isEmpty {
      for bird in getStandartBirds() {
        saveBird(bird: bird)
      }
    }
  }
  
  // MARK: - Eggs
  func createEgg(task: Task) {
    if let position = getFreePosition(eggs: eggs.value) {
      let egg = Egg(UID: UUID().uuidString, type: .Chiken, taskUID: task.UID, position: position, created: Date())
      saveEgg(egg: egg)
    }
  }
  
  func removeEgg(task: Task) {
    if let egg = eggs.value.first(where: { $0.taskUID == task.UID }) {
      removeEgg(egg: egg)
    }
  }
    
  // MARK: - Get Data From Core Data
 
  // birds
  func getBirdsCoreData() -> [BirdCoreData] {
    do {
      return try managedContext.fetch(BirdCoreData.fetchRequest())
    }
    catch {
      print(error.localizedDescription)
      return []
    }
  }
  
  // eggs
  func getEggsCoreData() -> [EggCoreData] {
    do {
      return try managedContext.fetch(EggCoreData.fetchRequest())
    }
    catch {
      print(error.localizedDescription)
      return []
    }
  }
  
  // MARK: - Save Data To Core Data

  // birds
  func saveBird(bird: Bird) {
    do {
      let fetchRequest = BirdCoreData.fetchRequest()
      fetchRequest.predicate = NSPredicate(
        format: "%K == %@",
        argumentArray: ["uid", bird.UID]
      )
      
      if let birdCoreData = try managedContext.fetch(fetchRequest).first {
        birdCoreData.loadFromBird(bird: bird)
      } else {
        BirdCoreData.init(context: managedContext, bird: bird)
      }
      
      try managedContext.save()
    }
    
    catch {
      print(error.localizedDescription)
    }
    
    return
  }
  
  // eggs
  func saveEgg(egg: Egg) {
    do {
      let fetchRequest = EggCoreData.fetchRequest()
      fetchRequest.predicate = NSPredicate(
        format: "%K == %@",
        argumentArray: ["uid", egg.UID]
      )
      
      if let eggCoreData = try managedContext.fetch(fetchRequest).first {
        eggCoreData.loadFromEgg(egg: egg)
      } else {
        EggCoreData.init(context: managedContext, egg: egg)
      }
      
      try managedContext.save()
    }
    
    catch {
      print(error.localizedDescription)
    }
  }
  
  
  // MARK: - Remove Data From Core Data
  func removeEgg(egg: Egg) {
    do {
      let fetchRequest = EggCoreData.fetchRequest()
      fetchRequest.predicate = NSPredicate(
        format: "%K == %@",
        argumentArray: ["uid", egg.UID]
      )
      
      for eggCoreData in try managedContext.fetch(fetchRequest) {
        try managedContext.delete(eggCoreData)
      }
      try managedContext.save()
    }
    
    catch {
      print(error.localizedDescription)
    }
  }
  
  // MARK: - Remove All Eggs and Birds
  func removeAllEggsCoreData() {
    do {
      for eggCoreData in try managedContext.fetch(EggCoreData.fetchRequest()) {
        managedContext.delete(eggCoreData)
      }
      try managedContext.save()
    }
    catch {
      print(error.localizedDescription)
    }
    return
  }
  
  func removeAllBirdsCoreData() {
    do {
      for eggCoreData in try managedContext.fetch(BirdCoreData.fetchRequest()) {
        managedContext.delete(eggCoreData)
      }
      try managedContext.save()
    }
    catch {
      print(error.localizedDescription)
    }
    return
  }
  
  // MARK: - Observe Data From Core DAta
  func startObserveCoreData() {
    NotificationCenter.default.addObserver(self, selector: #selector(observerSelector(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
  }
  
  // MARK: - Selector
  @objc func observerSelector(_ notification: Notification) {
    
    // Insert
    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
      for insertedObject in insertedObjects {
        
        // birdCoreData
        if let birdCoreData = insertedObject as? BirdCoreData {
          if let bird = Bird(birdCoreData: birdCoreData) {
            self.birds.accept(self.birds.value + [bird])
          }
        }
        
        // eggCoreData
        if let eggCoreData = insertedObject as? EggCoreData {
          if let egg = Egg(eggCoreData: eggCoreData) {
            self.eggs.accept(self.eggs.value + [egg])
          }
        }
      }
    }
    
    // Update
    if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
      for updatedObject in updatedObjects {
        
        // birdCoreData
        if let birdCoreData = updatedObject as? BirdCoreData {
          if let index = self.birds.value.firstIndex(where: { $0.UID == birdCoreData.uid }) {
            if let bird = Bird(birdCoreData: birdCoreData) {
              var birds = self.birds.value
              birds[index] = bird
              self.birds.accept(birds)
            }
          }
        }
        
        // eggCoreData
        if let eggCoreData = updatedObject as? EggCoreData {
          if let index = self.eggs.value.firstIndex(where: { $0.UID == eggCoreData.uid }) {
            if let egg = Egg(eggCoreData: eggCoreData) {
              var eggs = self.eggs.value
              eggs[index] = egg
              self.eggs.accept(eggs)
            }
          }
        }
      }
    }
    
    // Delete
    if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
      for deletedObject in deletedObjects {
        
        // birdCoreData
        if let birdCoreData = deletedObject as? BirdCoreData {
          if let index = self.birds.value.firstIndex(where: { $0.UID == birdCoreData.uid}) {
            var birds = self.birds.value
            birds.remove(at: index)
            self.birds.accept(birds)
          }
        }
        
        // eggCoreData
        if let eggCoreData = deletedObject as? EggCoreData {
          if let index = self.eggs.value.firstIndex(where: { $0.UID == eggCoreData.uid}) {
            var eggs = self.eggs.value
            eggs.remove(at: index)
            self.eggs.accept(eggs)
          }
        }
      }
    }
  }
  
  //MARK: - Helpers
  func getFreePosition(eggs: [Egg]) -> Int? {
    if eggs.first(where: { $0.position == 0 }) == nil { return 0 }
    if eggs.first(where: { $0.position == 1 }) == nil { return 1 }
    if eggs.first(where: { $0.position == 2 }) == nil { return 2 }
    if eggs.first(where: { $0.position == 3 }) == nil { return 3 }
    if eggs.first(where: { $0.position == 4 }) == nil { return 4 }
    if eggs.first(where: { $0.position == 5 }) == nil { return 5 }
    return nil
  }
  
  func getStandartBirds() -> [Bird] {
    return [
      
      // Chiken
      Bird.Chiken.Simple,
      Bird.Chiken.Student,
      Bird.Chiken.Business,
      Bird.Chiken.Cook,
      Bird.Chiken.Kid,
      Bird.Chiken.Sport,
      Bird.Chiken.Fashion,
      
      // Ostrich
      Bird.Ostrich.Simple,
      Bird.Ostrich.Student,
      Bird.Ostrich.Business,
      Bird.Ostrich.Cook,
      Bird.Ostrich.Kid,
      Bird.Ostrich.Sport,
      Bird.Ostrich.Fashion,
      
      // Owl
      Bird.Owl.Simple,
      Bird.Owl.Student,
      Bird.Owl.Business,
      Bird.Owl.Cook,
      Bird.Owl.Kid,
      Bird.Owl.Sport,
      Bird.Owl.Fashion,
      
      // Parrot
      Bird.Parrot.Simple,
      Bird.Parrot.Student,
      Bird.Parrot.Business,
      Bird.Parrot.Cook,
      Bird.Parrot.Kid,
      Bird.Parrot.Sport,
      Bird.Parrot.Fashion,
      
      // Penguin
      Bird.Penguin.Simple,
      Bird.Penguin.Student,
      Bird.Penguin.Business,
      Bird.Penguin.Cook,
      Bird.Penguin.Kid,
      Bird.Penguin.Sport,
      Bird.Penguin.Fashion,
      
      // Eagle
      Bird.Eagle.Simple,
      Bird.Eagle.Student,
      Bird.Eagle.Business,
      Bird.Eagle.Cook,
      Bird.Eagle.Kid,
      Bird.Eagle.Sport,
      Bird.Eagle.Fashion,
      
      // Dragon
      Bird.Dragon.Simple,
      Bird.Dragon.Student,
      Bird.Dragon.Business,
      Bird.Dragon.Cook,
      Bird.Dragon.Kid,
      Bird.Dragon.Sport,
      Bird.Dragon.Fashion
    ]
  }
}
