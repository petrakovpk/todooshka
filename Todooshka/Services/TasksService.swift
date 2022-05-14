//
//  TasksService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

import CoreData
import RxSwift
import RxCocoa
import YandexMobileMetrica

protocol HasTasksService {
    var tasksService: TasksService { get }
}

class TasksService {

  // MARK: - Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var managedContext: NSManagedObjectContext {
    return self.appDelegate.persistentContainer.viewContext
  }
  
  let tasks = BehaviorRelay<[Task]>(value: [])
 // var actions: [MainTaskListSceneAction] = []
  let removeTrigger = BehaviorRelay<RemoveMode?>(value: nil)
  let reloadDataSource = BehaviorRelay<Void>(value: ())
  
  // MARK: - Init
  init() {

    // load tasks from Core Data
    getTasksFromCoreData { tasksCoreData in
      tasksCoreData.forEach { taskCoreData in
        if let task = Task(taskCoreData: taskCoreData) {
          task.status == .Draft ? removeTasksFromCoreData(tasks: [task]) : self.tasks.accept(self.tasks.value + [task])
        }
      }
    }
    
    // start observing
    startObserveCoreData()
  }
  
  // MARK: - Get Data From Core Data
  func getTasksFromCoreData(completion: ([TaskCoreData]) -> ()) {
    do {
      completion(try managedContext.fetch(TaskCoreData.fetchRequest()))
    }
    catch {
      print(error.localizedDescription)
      completion([])
    }
  }
  
  // MARK: - Save Data To Core Data
  func saveTasksToCoreData(tasks: [Task]) {
    do {
      for task in tasks {
        
        let fetchRequest = TaskCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
          format: "%K == %@",
          argumentArray:["uid", task.UID])
        
        if let taskCoreData = try managedContext.fetch(fetchRequest).first {
          taskCoreData.loadFromTask(task: task)
        } else {
          TaskCoreData.init(context: managedContext, task: task)
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
  func removeTasksFromCoreData(tasks: [Task]) {
    do {
      for task in tasks {
        let fetchRequest = TaskCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
          format: "%K == %@",
          argumentArray:["uid", task.UID])
        
        if let taskCoreData = try managedContext.fetch(fetchRequest).first {
          managedContext.delete(taskCoreData)
        } 
        try managedContext.save()
      }
    }
    catch {
      print(error.localizedDescription)
    }
  }
  
  // MARK: - Remove All Tasks
  func removeAllTasksFromCoreData() {
    do {
      for taskCoreData in try managedContext.fetch(TaskCoreData.fetchRequest()) {
        managedContext.delete(taskCoreData)
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
        if let taskCoreData = insertedObject as? TaskCoreData {
          if let task = Task(taskCoreData: taskCoreData) {
            let tasks = self.tasks.value + [task]
            self.tasks.accept(tasks.sorted{ $0.created < $1.created })
            
            // YMMetrica
//            let params : [String : Any] = ["text": task.text, "description" : task.description, "type": task.type?.text]
//            YMMYandexMetrica.reportEvent("Create Task", parameters: params, onFailure: { (error) in
//                print("DID FAIL REPORT EVENT: %@", "Create task")
//              print("REPORT ERROR: %@", error.localizedDescription)
//            })
            
          }
        }
      }
    }
    
    // Update
    if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
      for updatedObject in updatedObjects {
        if let taskCoreData = updatedObject as? TaskCoreData {
          if let index = self.tasks.value.firstIndex(where: {$0.UID == taskCoreData.uid}) {
            if let task = Task(taskCoreData: taskCoreData) {
              var tasks = self.tasks.value
              tasks[index] = task
              self.tasks.accept(tasks.sorted{ $0.created < $1.created })
            }
          }
        }
      }
    }
    
    // Remove
    if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
      for deletedObject in deletedObjects {
        if let taskCoreData = deletedObject as? TaskCoreData {
          if let index = self.tasks.value.firstIndex(where: {$0.UID == taskCoreData.uid}) {
            var tasks = self.tasks.value
            tasks.remove(at: index)
            self.tasks.accept(tasks)
          }
        }
      }
    }
  }
  
}
