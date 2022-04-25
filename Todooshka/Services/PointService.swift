//
//  PointService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

import CoreData
import RxSwift
import RxCocoa

protocol HasPointService {
  var pointService: PointService { get }
}

class PointService {
  
  // MARK: - Core Data Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var managedContext: NSManagedObjectContext {
    return self.appDelegate.persistentContainer.viewContext
  }
  
  // MARK: - Score Properties
  let points = BehaviorRelay<[Point]>(value: [])
  
  // MARK: - Init
  init() {

  }
  
  // MARK: - Get Data From Core Data
  func getPointsCoreData() -> [PointCoreData] {
    do {
      return try managedContext.fetch(PointCoreData.fetchRequest())
    }
    catch {
      print(error.localizedDescription)
      return []
    }
  }
  
  // MARK: - Save Data To Core Data
  func createOneFeather(completion: @escaping () -> Result<Point, Error>) {

  }
  
  func savePointToCoreData(point: Point) {
    do {
      let fetchRequest = PointCoreData.fetchRequest()
      fetchRequest.predicate = NSPredicate(
        format: "%K == %@",
        argumentArray: ["uid", point.UID]
      )
      
      for pointCoreData in try managedContext.fetch(fetchRequest) {
        try managedContext.delete(pointCoreData)
      }
      
      PointCoreData.init(context: managedContext, point: point)
      try managedContext.save()
    }
    
    catch {
      print(error.localizedDescription)
    }
    
    return
  }
  
  
  // MARK: - Remove Data To Core Data
  func removeAllPointsFromCoreData() {
    do {
      for point in try managedContext.fetch(PointCoreData.fetchRequest()) {
        managedContext.delete(point)
      }
      try managedContext.save()
    }
    catch {
      print(error.localizedDescription)
    }
    return
  }
  
  // MARK: - Observers
  func observeData() {
    NotificationCenter.default.addObserver(self, selector: #selector(observerSelector(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
  }
  
  // MARK: - Selector
  @objc func observerSelector(_ notification: Notification) {
    
    // Insert
    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
      for insertedObject in insertedObjects {
        if let pointCoreData = insertedObject as? PointCoreData {
          if let point = Point(pointCoreData: pointCoreData) {
            self.points.accept(self.points.value + [point])
          }
        }
      }
    }
    
    // Update
    if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
      for updatedObject in updatedObjects {
        if let pointCoreData = updatedObject as? PointCoreData {
          if let index = self.points.value.firstIndex(where: { $0.UID == pointCoreData.uid }) {
            if let point = Point(pointCoreData: pointCoreData) {
              var points = self.points.value
              points[index] = point
              self.points.accept(points)
            }
          }
        }
      }
    }
    
    // Delete
    if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
      for deletedObject in deletedObjects {
        if let pointCoreData = deletedObject as? PointCoreData {
          if let index = self.points.value.firstIndex(where: { $0.UID == pointCoreData.uid}) {
            var points = self.points.value
            points.remove(at: index)
            self.points.accept(points)
          }
        }
      }
    }
  }
}
