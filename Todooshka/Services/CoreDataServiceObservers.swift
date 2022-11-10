//
//  CoreDataServiceObservers.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

import CoreData

extension CoreDataService {
  // MARK: - Selector
  @objc func observerSelector(_ notification: Notification) {
    // Insert
    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
      for insertedObject in insertedObjects {
        if let coreDataTask = insertedObject as? CoreDataTask {
          if let task = Task(coreDataTask: coreDataTask) {
            var tasks = self.tasks.value + [task]
            tasks.sort { return $0.createdTimeIntervalSince1970 < $1.createdTimeIntervalSince1970 }
            self.tasks.accept(tasks)

            let params: [String: Any] = ["text": task.text, "description": task.description as Any, "type": task.type?.text]
            YMMYandexMetrica.reportEvent("Create Task", parameters: params, onFailure: { error in
                print("DID FAIL REPORT EVENT: %@", "Create task")
              print("REPORT ERROR: %@", error.localizedDescription)
            })
          }
        }
        if let coreDataTaskType = insertedObject as? CoreDataTaskType {
          if let type = TaskType(coreDataTaskType: coreDataTaskType) {
            var types = self.taskTypes.value + [type]
            types.sort { return $0.orderNumber < $1.orderNumber }
            self.taskTypes.accept(types)

            let params: [String: Any] = ["text": type.text, "createdDate": type.identity]
            YMMYandexMetrica.reportEvent("Create Type", parameters: params, onFailure: { error in
                print("DID FAIL REPORT EVENT: %@", "Create type")
              print("REPORT ERROR: %@", error.localizedDescription)
            })
          }
        }
      }
    }

    // Update
    if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
      for updatedObject in updatedObjects {
        if let coreDataTask = updatedObject as? CoreDataTask {
          if let index = self.tasks.value.firstIndex(where: { $0.UID == coreDataTask.uid }) {
            if let task = Task(coreDataTask: coreDataTask) {
              var tasks = self.tasks.value
              tasks[index] = task
              tasks.sort { return $0.createdTimeIntervalSince1970 < $1.createdTimeIntervalSince1970 }
              self.tasks.accept(tasks)
            }
          }
        }
        if let coreDataTaskType = updatedObject as? CoreDataTaskType {
          if let index = self.taskTypes.value.firstIndex(where: { $0.identity == coreDataTaskType.uid }) {
            if let type = TaskType(coreDataTaskType: coreDataTaskType) {
              var types = self.taskTypes.value
              types[index] = type
              types.sort { return $0.orderNumber < $1.orderNumber }
              self.taskTypes.accept(types)
            }
          }
        }
      }
    }

    // Delete
    if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
      for deletedObject in deletedObjects {
        if let coreDataTask = deletedObject as? CoreDataTask {
          if let index = self.tasks.value.firstIndex(where: { $0.UID == coreDataTask.uid }) {
            var tasks = self.tasks.value
            tasks.remove(at: index)
            self.tasks.accept(tasks)
          }
        }
        if let coreDataTaskType = deletedObject as? CoreDataTaskType {
          if let index = self.taskTypes.value.firstIndex(where: { $0.identity == coreDataTaskType.uid }) {
            var types = self.taskTypes.value
            types.remove(at: index)
            self.taskTypes.accept(types)
          }
        }
      }
    }
  }
}
