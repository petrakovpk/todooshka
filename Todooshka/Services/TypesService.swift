//
//  TypesService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import YandexMobileMetrica

protocol HasTypesService {
    var typesService: TypesService { get }
}

class TypesService {
  
  // MARK: - Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var managedContext: NSManagedObjectContext {
    return self.appDelegate.persistentContainer.viewContext
  }
  
  let types = BehaviorRelay<[TaskType]>(value: [])
  let typeRemovingIsRequired = BehaviorRelay<TaskType?>(value: nil)
  let allTypesRemovingIsRequired = BehaviorRelay<Bool>(value: false)
  let selectedTypeColor = BehaviorRelay<TypeColor>(value: TaskType.Standart.Empty.color)
  let selectedTypeIcon = BehaviorRelay<Icon>(value: TaskType.Standart.Empty.icon)
  
  // MARK: - Init
  init() {
    
    // load types from Core Data
    self.types.accept(
      getTypesFromCoreData()
      .compactMap{ TaskType(typeCoreData: $0) }
      .sorted{ $0.serialNum < $1.serialNum }
    )
    
    startObserveCoreData()
    
    if types.value.isEmpty {
      saveTypesToCoreData(types: getStandartTypes())
    }
    
  }
  
  // MARK: - Get Data From Core Data
  func getTypesFromCoreData() -> [TypeCoreData] {
    do {
      return try managedContext.fetch(TypeCoreData.fetchRequest())
    }
    catch {
      print(error.localizedDescription)
      return []
    }
  }
  
  // MARK: - Save Data To Core Data
  func saveTypesToCoreData(types: [TaskType]) {
    do {
      for type in types {
        let fetchRequest = TypeCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
          format: "%K == %@",
          argumentArray:["uid", type.UID])
        
        if let typeCoreData = try managedContext.fetch(fetchRequest).first {
          typeCoreData.loadFromType(type: type)
        } else {
          TypeCoreData.init(context: managedContext, type: type)
        }
        try managedContext.save()
      }
      return
    }
    
    catch {
      print(error.localizedDescription)
      return
    }
  }
  
  // MARK: - Remove Data From Core Data
  func removeTypesFromCoreData(types: [TaskType], completion: TodooshkaCompletion? ) {
    do {
      let fetchRequest = TypeCoreData.fetchRequest()
      fetchRequest.predicate = NSPredicate(
        format: "%K == %@",
        argumentArray:["in", types.map{ return $0.UID }]
      )
      
      for typeCoreData in try managedContext.fetch(fetchRequest) {
        try managedContext.delete(typeCoreData)
      }
      
      try managedContext.save()
      completion?(nil)
    }
    
    catch {
      print(error.localizedDescription)
      completion?(error)
    }
  }
  
  func removeAllTypesFromCoreData() {
    do {
      let coreDataTaskTypes = try managedContext.fetch(TypeCoreData.fetchRequest())
      for coreDataTaskType in coreDataTaskTypes {
        managedContext.delete(coreDataTaskType)
      }
      try managedContext.save()
    }
    catch {
      print(error.localizedDescription)
    }
    return
  }
  
  // MARK: - Observers
  func startObserveCoreData() {
    NotificationCenter.default.addObserver(self, selector: #selector(observerSelector(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
  }
  
  // MARK: - Selector
  @objc func observerSelector(_ notification: Notification) {
    
    // Insert
    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
      for insertedObject in insertedObjects {
        if let typeCoreData = insertedObject as? TypeCoreData {
          if let type = TaskType(typeCoreData: typeCoreData) {
            let types = self.types.value + [type]
            self.types.accept(types.sorted{ $0.serialNum < $1.serialNum })
          }
        }
      }
    }
    
    // Update
    if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
      for updatedObject in updatedObjects {
        if let typeCoreData = updatedObject as? TypeCoreData {
          if let index = self.types.value.firstIndex(where: { $0.identity == typeCoreData.uid }) {
            if let type = TaskType(typeCoreData: typeCoreData) {
              var types = self.types.value
              types[index] = type
              self.types.accept(types.sorted{ $0.serialNum < $1.serialNum })
            //  print("обновили", type.text)
            }
          }
        }
      }
    }
    
    // Delete
    if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
      for deletedObject in deletedObjects {
        if let typeCoreData = deletedObject as? TypeCoreData {
          if let index = self.types.value.firstIndex(where: { $0.identity == typeCoreData.uid }) {
            var types = self.types.value
            types.remove(at: index)
            self.types.accept(types)
          }
        }
      }
    }
  }
  
  //MARK: - Standart Types
  func getStandartTypes() -> [TaskType] {
    return [
      .Standart.Sport,
      .Standart.Fashion,
      .Standart.Cook,
      .Standart.Business,
      .Standart.Student,
      .Standart.Empty,
      .Standart.Kid,
      .Standart.Home,
      .Standart.Love,
      .Standart.Pet
    ]
  }
}

