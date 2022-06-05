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
  let mainTaskListSceneActions = BehaviorRelay<[SceneAction]>(value: [])
  
  // MARK: - Init
  init() {
    
    // removeAll
    removeAllBirdsFromCoreData()
    
    // Get Birds from Core Data
    getBirdsFromCoreData { birdsCoreData in
      birdsCoreData.forEach { birdCoreData in
        if let bird = Bird(birdCoreData: birdCoreData) {
          self.birds.accept(self.birds.value + [bird])
        }
      }
    }
    
    // Start Observing
    startObserveCoreData()
    
    // If first loading - create standart
    if self.birds.value.isEmpty {
      getStandartBirds { birds in
        birds.forEach { saveBirdToCoreData(bird: $0) }
      }
    }
  }
  
  func linkBirdToTypeUID(bird: Bird, type: TaskType) {
    // удаляем типы из всех птиц аналогичного типа
    birds.value
      .filter({
        $0.clade == bird.clade &&
        $0.typesUID.contains(where: { $0 == type.UID })})
      .forEach { bird in
        var bird = bird
        bird.typesUID.removeAll(type.UID)
        self.saveBirdToCoreData(bird: bird)
      }
    
    // добавляем тип
    var bird = bird
    bird.typesUID.append(type.UID)
    saveBirdToCoreData(bird: bird)
  }
  
  // MARK: - Get Data From Core Data
  func getBirdsFromCoreData(completion: ([BirdCoreData]) -> Void ) {
    do {
      completion(try managedContext.fetch(BirdCoreData.fetchRequest()))
    }
    catch {
      print(error.localizedDescription)
      completion([])
    }
  }

  // MARK: - Save Data To Core Data
  func saveBirdToCoreData(bird: Bird) {
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
  
  // MARK: - Remove Data From Core Data
  func removeAllBirdsFromCoreData() {
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
        if let birdCoreData = insertedObject as? BirdCoreData {
          if let bird = Bird(birdCoreData: birdCoreData) {
            self.birds.accept(self.birds.value + [bird])
          }
        }
      }
    }
    
    // Update
    if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
      for updatedObject in updatedObjects {
        if let birdCoreData = updatedObject as? BirdCoreData {
          if let index = self.birds.value.firstIndex(where: { $0.UID == birdCoreData.uid }) {
            if let bird = Bird(birdCoreData: birdCoreData) {
              var birds = self.birds.value
              birds[index] = bird
              self.birds.accept(birds)
            }
          }
        }
      }
    }
    
    // Delete
    if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
      for deletedObject in deletedObjects {
        if let birdCoreData = deletedObject as? BirdCoreData {
          if let index = self.birds.value.firstIndex(where: { $0.UID == birdCoreData.uid}) {
            var birds = self.birds.value
            birds.remove(at: index)
            self.birds.accept(birds)
          }
        }
      }
    }
  }
  
  //MARK: - Helpers
  func getStandartBirds(completion: ([Bird]) -> Void) {
    completion([
      
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
    ])
  }
}
