//
//  MigrationService.swift
//  Todooshka
//
//  Created by Pavel Petakov on 10.10.2022.
//

import CoreData
import Firebase
import RxSwift
import RxCocoa

protocol HasMigrationService {
  var migrationService: MigrationService { get }
}

class MigrationService {
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  var managedContext: NSManagedObjectContext? {
    self.appDelegate?.persistentContainer.viewContext
  }

  // MARK: - Properties
  var kinfOfTaskNameToUID: [String: String] = [
    "Работа": KindOfTask.Standart.Business.UID,
    "Семья": KindOfTask.Standart.Cook.UID,
    "Дом": KindOfTask.Standart.Home.UID,
    "Вторая половинка": KindOfTask.Standart.Love.UID,
    "Домашнее животное": KindOfTask.Standart.Pet.UID,
    "Спорт": KindOfTask.Standart.Sport.UID
  ]

  var statusMapping: [String: String] = [
    "completed": "Completed",
    "deleted": "Deleted",
    "idea": "Idea",
    "inProgress": "InProgress"
  ]

  // MARK: - Init
  init() {
    do {
      guard
        let managedContext = self.managedContext,
        let entity = NSEntityDescription.entity(forEntityName: Task.entityName, in: managedContext)
      else { return }

      var coreDataTaskTypeUIDToText: [String: String] = [:]

      // CoreDataTaskTypes
      let coreDataTaskTypes = try managedContext.fetch(CoreDataTaskType.fetchRequest())

      for coreDataTaskType in coreDataTaskTypes {
        if let text = coreDataTaskType.value(forKey: "text") as? String,
           let uid = coreDataTaskType.value(forKey: "uid") as? String {
          coreDataTaskTypeUIDToText[uid] = text
        }
      }

      // CoreDataTasks
      let coreDataTasks = try managedContext.fetch(CoreDataTask.fetchRequest())
      for coreDataTask in coreDataTasks {
        guard
          let uid = coreDataTask.value(forKey: "uid") as? String,
          let createdTimeIntervalSince1970 = coreDataTask.value(forKey: "createdTimeIntervalSince1970") as? TimeInterval
        else { return }

        var task = Task(
          UID: uid,
          text: coreDataTask.value(forKey: "text") as? String ?? "",
          description: coreDataTask.value(forKey: "longText") as? String,
          kindOfTaskUID: KindOfTask.Standart.Simple.UID,
          status: .inProgress,
          created: Date(timeIntervalSince1970: createdTimeIntervalSince1970),
          closed: nil,
          planned: nil
        )

        if let oldStatus = coreDataTask.value(forKey: "status") as? String,
           let newStatus = statusMapping[oldStatus],
           let status = TaskStatus(rawValue: newStatus) {
          task.status = status
        }

        if let closedTimeIntervalSince1970 = coreDataTask.value(forKey: "closedTimeIntervalSince1970") as? TimeInterval {
          task.closed = Date(timeIntervalSince1970: closedTimeIntervalSince1970)
        }

        if let lastModifiedTimeIntervalsince1970 = coreDataTask.value(forKey: "lastmodifiedtimeintervalsince1970") as? TimeInterval {
          task.lastModified = Date(timeIntervalSince1970: lastModifiedTimeIntervalsince1970)
        }

        if let type = coreDataTask.value(forKey: "type") as? String,
           let typeName = coreDataTaskTypeUIDToText[type],
           let kindOfTaskUID = kinfOfTaskNameToUID[typeName] {
          task.kindOfTaskUID = kindOfTaskUID
        }

        task.userUID = coreDataTask.value(forKey: "userUID") as? String ?? Auth.auth().currentUser?.uid

        let taskObject = NSManagedObject(entity: entity, insertInto: managedContext)
        taskObject.setValue(task.UID, forKey: "uid")
        taskObject.setValue(task.closed, forKey: "closed")
        taskObject.setValue(task.created, forKey: "created")
        taskObject.setValue(task.description, forKey: "desc")
        taskObject.setValue(task.index, forKey: "index")
        taskObject.setValue(task.kindOfTaskUID, forKey: "kindOfTaskUID")
        taskObject.setValue(task.planned, forKey: "planned")
        taskObject.setValue(task.status.rawValue, forKey: "statusRawValue")
        taskObject.setValue(task.text, forKey: "text")
        taskObject.setValue(task.userUID, forKey: "userUID")
        taskObject.setValue(task.lastModified, forKey: "lastModified")

        // delete
        managedContext.delete(coreDataTask)

        try managedContext.save()
      }
    } catch {
      print(error.localizedDescription)
    }
  }
}
