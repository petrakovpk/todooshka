//
//  PointService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

import CoreData
import RxSwift
import RxCocoa
//
// protocol HasGameCurrencyService {
//  var gameCurrencyService: GameCurrencyService { get }
// }
//
// class GameCurrencyService {
//  
//  // MARK: - Core Data Properties
//  let appDelegate = UIApplication.shared.delegate as! AppDelegate
//  var managedContext: NSManagedObjectContext {
//    return self.appDelegate.persistentContainer.viewContext
//  }
//  
//  // MARK: - Score Properties
//  let gameCurrency = BehaviorRelay<[GameCurrency]>(value: [])
//  
//  // MARK: - Init
//  init() {
//    
//   // removeAllGameCurrencyFromCoreData()
//
//    // Get Points from Core Data
//    getGameCurrencyCoreData { gameCurrencyCoreData in
//      gameCurrencyCoreData.forEach { gameCurrencyCoreData in
//        if let gameCurrency = GameCurrency(gameCurrencyCoreData: gameCurrencyCoreData) {
//          self.gameCurrency.accept(self.gameCurrency.value + [gameCurrency])
//        }
//      }
//    }
//    
//    observeData()
//    
//  }
//  
//  // MARK: - Get Data From Core Data
//  func getGameCurrencyCoreData(completion: ([GameCurrencyCoreData]) -> Void) {
//    do {
//      completion( try managedContext.fetch(GameCurrencyCoreData.fetchRequest()))
//    }
//    catch {
//      print(error.localizedDescription)
//      completion([])
//    }
//  }
//  
//  // MARK: - Save Data To Core Data
//  func createGameCurrency(task: Task) {
//    if gameCurrency.value.count(where: { $0.created >= Date().startOfDay }) < 6 {
//      self.saveGameCurrencyToCoreData(gameCurrency: GameCurrency(UID: UUID().uuidString, currency: .Feather, created: Date(), task: task))
//    }
//  }
//  
//  func removeGameCurrency(task: Task) {
//    if let gameCurrency = gameCurrency.value.first(where: { $0.taskUID == task.UID }) {
//      self.removeGameCurrencyFromCoreData(gameCurrency: gameCurrency)
//    }
//  }
//  
//  func saveGameCurrencyToCoreData(gameCurrency: GameCurrency) {
//    do {
//      let fetchRequest = GameCurrencyCoreData.fetchRequest()
//      fetchRequest.predicate = NSPredicate(
//        format: "%K == %@",
//        argumentArray: ["uid", gameCurrency.UID]
//      )
//      
//      for pointCoreData in try managedContext.fetch(fetchRequest) {
//        managedContext.delete(pointCoreData)
//      }
//      
//      GameCurrencyCoreData.init(context: managedContext, gameCurrency: gameCurrency)
//      try managedContext.save()
//    }
//    
//    catch {
//      print(error.localizedDescription)
//    }
//    
//    return
//  }
//  
//  
//  // MARK: - Remove Data From Core Data
//  func removeGameCurrencyFromCoreData(gameCurrency: GameCurrency) {
//    do {
//      let fetchRequest = GameCurrencyCoreData.fetchRequest()
//      fetchRequest.predicate = NSPredicate(
//        format: "%K == %@",
//        argumentArray: ["uid", gameCurrency.UID]
//      )
//      
//      for pointCoreData in try managedContext.fetch(fetchRequest) {
//        managedContext.delete(pointCoreData)
//      }
//      try managedContext.save()
//    }
//    
//    catch {
//      print(error.localizedDescription)
//    }
//  }
//  
//  func removeAllGameCurrencyFromCoreData() {
//    do {
//      for point in try managedContext.fetch(GameCurrencyCoreData.fetchRequest()) {
//        managedContext.delete(point)
//      }
//      try managedContext.save()
//    }
//    catch {
//      print(error.localizedDescription)
//    }
//    return
//  }
//  
//  // MARK: - Observers
//  func observeData() {
//    NotificationCenter.default.addObserver(self, selector: #selector(observerSelector(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
//  }
//  
//  // MARK: - Selector
//  @objc func observerSelector(_ notification: Notification) {
//    
//    // Insert
//    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
//      for insertedObject in insertedObjects {
//        if let gameCurrencyCoreData = insertedObject as? GameCurrencyCoreData {
//          if let gameCurrency = GameCurrency(gameCurrencyCoreData: gameCurrencyCoreData) {
//            self.gameCurrency.accept(self.gameCurrency.value + [gameCurrency])
//          }
//        }
//      }
//    }
//    
//    // Update
//    if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
//      for updatedObject in updatedObjects {
//        if let gameCurrencyCoreData = updatedObject as? GameCurrencyCoreData {
//          if let index = self.gameCurrency.value.firstIndex(where: { $0.UID == gameCurrencyCoreData.uid }) {
//            if let newGameCurrency = GameCurrency(gameCurrencyCoreData: gameCurrencyCoreData) {
//              var gameCurrency = self.gameCurrency.value
//              gameCurrency[index] = newGameCurrency
//              self.gameCurrency.accept(gameCurrency)
//            }
//          }
//        }
//      }
//    }
//    
//    // Delete
//    if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
//      for deletedObject in deletedObjects {
//        if let gameCurrencyCoreData = deletedObject as? GameCurrencyCoreData {
//          if let index = self.gameCurrency.value.firstIndex(where: { $0.UID == gameCurrencyCoreData.uid}) {
//            var gameCurrency = self.gameCurrency.value
//            gameCurrency.remove(at: index)
//            self.gameCurrency.accept(gameCurrency)
//          }
//        }
//      }
//    }
//  }
// }
