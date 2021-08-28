//
//  CoreDataService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 29.06.2021.
//

import Foundation
import Firebase
import RxFlow
import RxSwift
import RxCocoa
import CoreData

protocol HasCoreDataService {
    var coreDataService: CoreDataService { get }
}

class CoreDataService {
    
    //MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext: NSManagedObjectContext {
        return self.appDelegate.persistentContainer.viewContext
    }
    
    let disposeBag = DisposeBag()
    
    let calendarSelectedDate = BehaviorRelay<Date>(value: Date())
    
    let tasks = BehaviorRelay<[Task]>(value: [])
    let taskTypes = BehaviorRelay<[TaskType]>(value: [])
    let selectedTaskType = BehaviorRelay<TaskType?>(value: nil)
    var handleAuth: AuthStateDidChangeListenerHandle!
    
    //MARK: - Init
    init() {
        setupInitialTaskTypesIsNeeded()
        
        loadTaskTypesFromCoreData()
        loadTasksFromCoreData()
        
        startObserveCoreData()
        
        startOnlineWorking()
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(handleAuth)
    }
    
    //MARK: - Settings
    func setupInitialTaskTypesIsNeeded() {
        let fetchRequest = NSFetchRequest<CoreDataTaskType>(entityName: "CoreDataTaskType")
        do {
            let coreDataTaskTypes = try managedContext.fetch(fetchRequest)
            if coreDataTaskTypes.isEmpty {
                let type0 = TaskType(UID: "work", systemImageName: "hammer", text: "Работа", orderNumber: 0)
                let type1 = TaskType(UID: "family", systemImageName: "person.3", text: "Семья", orderNumber: 1)
                let type2 = TaskType(UID: "house", systemImageName: "house", text: "Дом", orderNumber: 2)
                let type3 = TaskType(UID: "love", systemImageName: "suit.heart", text: "Любимка", orderNumber: 3)
                let type4 = TaskType(UID: "business", systemImageName: "gift", text: "Бизнес", orderNumber: 4)
                let type5 = TaskType(UID: "sport", systemImageName: "sun.max", text: "Спорт", orderNumber: 5)
                
                saveTaskTypesToCoreData(types: [type0,type1,type2,type3,type4,type5], completion: nil)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Offlain and Online modes
    
    
    func startOnlineWorking() {
        
        handleAuth = Auth.auth().addStateDidChangeListener {[weak self] (auth, user) in
            guard let self = self else { return }
            if let user = user {
                self.loadTasksFromCoreData()
                self.startObserveFirebaseForUser(user: user)
                self.startUploadDataToFirebaseForUser(user: user)
            } else {
                self.loadTasksFromCoreData()
                TASKS_REF.removeAllObservers()
                TASK_TYPES_REF.removeAllObservers()
            }
        }
        
    }
    
    func updateUserToCoreDataTasks(userUID: String) {
        let fetchRequest = NSFetchRequest<CoreDataTask>(entityName: "CoreDataTask")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray:["userUID", nil])

        do {
            let coreDataTasks = try managedContext.fetch(fetchRequest)
            for coreDataTask in coreDataTasks {
                coreDataTask.userUID = userUID
                try managedContext.save()
            }
        }
        catch {
            print(error.localizedDescription)
            
        }
    }
    
    //MARK: - Cora Data - Load data when App is initing
    func loadTasksFromCoreData() {
        let fetchRequest = NSFetchRequest<CoreDataTask>(entityName: "CoreDataTask")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray:["userUID", Auth.auth().currentUser?.uid])
        do {
            let coreDataTasks = try managedContext.fetch(fetchRequest)
            
            var tasks = coreDataTasks.compactMap{ Task(coreDataTask: $0) }
            tasks.sort{ return $0.createdTimeIntervalSince1970 < $1.createdTimeIntervalSince1970 }
            self.tasks.accept(tasks)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func loadTaskTypesFromCoreData() {
        let fetchRequest = NSFetchRequest<CoreDataTaskType>(entityName: "CoreDataTaskType")
        do {
            let coreDataTaskTypes = try managedContext.fetch(fetchRequest)
            var taskTypes = coreDataTaskTypes.compactMap{ return TaskType(coreDataTaskType: $0)}
            taskTypes.sort{ return $0.orderNumber < $1.orderNumber }
            self.taskTypes.accept(taskTypes)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Core Data - Observers
    func startObserveCoreData() {
        NotificationCenter.default.addObserver(self, selector: #selector(observerSelector(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    @objc func observerSelector(_ notification: Notification) {
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
            for insertedObject in insertedObjects {
                if let coreDataTask = insertedObject as? CoreDataTask {
                    if let task = Task(coreDataTask: coreDataTask) {
                        var tasks = self.tasks.value + [task]
                        tasks.sort{ return $0.createdTimeIntervalSince1970 < $1.createdTimeIntervalSince1970 }
                        self.tasks.accept(tasks)
                    }
                }
                if let coreDataTaskType = insertedObject as? CoreDataTaskType {
                    if let type = TaskType(coreDataTaskType: coreDataTaskType) {
                        var types = self.taskTypes.value + [type]
                        types.sort{ return $0.orderNumber < $1.orderNumber }
                        self.taskTypes.accept(types)
                    }
                }
            }
        }
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
            for updatedObject in updatedObjects {
                if let coreDataTask = updatedObject as? CoreDataTask {
                    if let index = self.tasks.value.firstIndex(where: {$0.UID == coreDataTask.uid}) {
                        if let task = Task(coreDataTask: coreDataTask) {
                            var tasks = self.tasks.value
                            tasks[index] = task
                            tasks.sort{ return $0.createdTimeIntervalSince1970 < $1.createdTimeIntervalSince1970 }
                            self.tasks.accept(tasks)
                        }
                    }
                }
                if let coreDataTaskType = updatedObject as? CoreDataTaskType {
                    if let index = self.taskTypes.value.firstIndex(where: {$0.UID == coreDataTaskType.uid}) {
                        if let type = TaskType(coreDataTaskType: coreDataTaskType) {
                            var types = self.taskTypes.value
                            types[index] = type
                            types.sort{ return $0.orderNumber < $1.orderNumber }
                            self.taskTypes.accept(types)
                        }
                    }
                }
            }
        }
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
            for deletedObject in deletedObjects {
                if let coreDataTask = deletedObject as? CoreDataTask {
                    if let index = self.tasks.value.firstIndex(where: {$0.UID == coreDataTask.uid}) {
                        var tasks = self.tasks.value
                        tasks.remove(at: index)
                        self.tasks.accept(tasks)
                    }
                }
                if let coreDataTaskType = deletedObject as? CoreDataTaskType {
                    if let index = self.taskTypes.value.firstIndex(where: {$0.UID == coreDataTaskType.uid}) {
                        var types = self.taskTypes.value
                        types.remove(at: index)
                        self.taskTypes.accept(types)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Firebase - Observers
    func startObserveFirebaseForUser(user: User) {
        TASKS_REF.child(user.uid).observe(.childAdded) { taskSnapshot in
            if let task = Task(snapshot: taskSnapshot) {
                if task.status == .hardDeleted {
                    self.removeTaskFromCoreData(task: task, completion: nil)
                } else {
                    self.saveTasksToCoreData(tasks: [task], completion: nil)
                }
            }
        }
        
        TASKS_REF.child(user.uid).observe(.childRemoved) { taskSnapshot in
            if let task = Task(snapshot: taskSnapshot) {
                self.removeTaskFromCoreData(task: task, completion: nil)
            }
        }
        
        TASKS_REF.child(user.uid).observe(.childChanged) { taskSnapshot in
            if let task = Task(snapshot: taskSnapshot) {
                if task.status == .hardDeleted {
                    self.removeTaskFromCoreData(task: task, completion: nil)
                } else {
                    self.saveTasksToCoreData(tasks: [task], completion: nil)
                }
            }
        }
        
        TASK_TYPES_REF.child(user.uid).observe(.childAdded) { taskTypeSnapshot in
            if let taskType = TaskType(snapshot: taskTypeSnapshot) {
                self.saveTaskTypesToCoreData(types: [taskType], completion: nil)
            }
        }
        
        TASK_TYPES_REF.child(user.uid).observe(.childRemoved) { taskTypeSnapshot in
            if let taskType = TaskType(snapshot: taskTypeSnapshot) {
                self.removeTaskTypeFromCoreData(type: taskType, completion: nil)
            }
        }
        
        TASK_TYPES_REF.child(user.uid).observe(.childChanged) { taskTypeSnapshot in
            if let taskType = TaskType(snapshot: taskTypeSnapshot) {
                self.saveTaskTypesToCoreData(types: [taskType], completion: nil)
            }
        }
        
    }
    
    func startUploadDataToFirebaseForUser(user: User) {
        self.tasks
            .filter{ $0.count > 0}
            .bind{ [weak self] tasks in
                guard let self = self else { return }
                self.saveTasksToFirebase(tasks: tasks, completion: nil)
            }.disposed(by: disposeBag)
    }

    
    //MARK: - Core Data - Save
    func saveTasksToCoreData(tasks: [Task], completion: TodooshkaCompletion? ) {

        var coreDataTask: CoreDataTask!
        let fetchRequest = NSFetchRequest<CoreDataTask>(entityName: "CoreDataTask")
        fetchRequest.predicate = NSPredicate(format: "%K in %@", argumentArray:["uid", tasks.map{return $0.UID}])
        
        do {
            let coreDataTasks = try managedContext.fetch(fetchRequest)
            
            for task in tasks {
                
                if coreDataTasks.first(where: { $0.uid == task.UID }) == nil {
                    coreDataTask = CoreDataTask(context: managedContext)
                } else {
                    coreDataTask = coreDataTasks.first(where: { $0.uid == task.UID })
                }
                
                if task.lastUpdateDateTime <=
                    coreDataTask.lastmodifiedtimeintervalsince1970 as? TimeInterval ?? 0.0 { return }
                
                coreDataTask.uid = task.UID
                coreDataTask.text = task.text
                coreDataTask.longText = task.description
                coreDataTask.status = task.status.rawValue
                coreDataTask.type = task.type
                coreDataTask.createdTimeIntervalSince1970 = task.createdTimeIntervalSince1970 as NSNumber
                coreDataTask.closedTimeIntervalSince1970 = task.closedTimeIntervalSince1970 as NSNumber?
                coreDataTask.lastmodifiedtimeintervalsince1970 = task.lastUpdateDateTime as NSNumber?
                coreDataTask.userUID = Auth.auth().currentUser?.uid
                
                try managedContext.save()
            }
            
            
            return
        }
        
        catch {
            print(error.localizedDescription)
            completion?(error)
            return
        }
    }
    
    func saveTaskTypesToCoreData(types: [TaskType], completion: TodooshkaCompletion? ) {
        completion?(nil)
        var coreDataTaskType: CoreDataTaskType!
        let fetchRequest = NSFetchRequest<CoreDataTaskType>(entityName: "CoreDataTaskType")
        fetchRequest.predicate = NSPredicate(format: "%K in %@", argumentArray:["uid", types.map{return $0.UID}])
        
        do {
            let coreDataTaskTypes = try managedContext.fetch(fetchRequest)
            
            for type in types {
                
                if coreDataTaskTypes.first(where: { $0.uid == type.UID }) == nil {
                    coreDataTaskType = CoreDataTaskType(context: managedContext)
                } else {
                    coreDataTaskType = coreDataTaskTypes.first(where: { $0.uid == type.UID })
                }
                
                coreDataTaskType.uid = type.UID
                coreDataTaskType.text = type.text
                coreDataTaskType.systemimagename = type.systemImageName
                coreDataTaskType.ordernumber = type.orderNumber as NSNumber?
                
                try managedContext.save()
            }
            
            
            return
        }
        
        catch {
            print(error.localizedDescription)
            completion?(error)
            return
        }
        
    }
    
    //MARK: - Core Data - Remove
    func removeTaskFromCoreData(task: Task, completion: TodooshkaCompletion? ) {
        completion?(nil)
        let fetchRequest = NSFetchRequest<CoreDataTask>(entityName: "CoreDataTask")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray:["uid", task.UID])
        
        do {
            let coreDataTasks = try managedContext.fetch(fetchRequest)
            for coreDataTask in coreDataTasks {
                managedContext.delete(coreDataTask)
            }
            try managedContext.save()
        }
        catch {
            print(error.localizedDescription)
            completion?(error)
        }
    }
    
    func removeTasksFromCoreData(tasks: [Task], completion: @escaping TodooshkaCompletion ) {
        let fetchRequest = NSFetchRequest<CoreDataTask>(entityName: "CoreDataTask")
        fetchRequest.predicate = NSPredicate(format: "%K in %@", argumentArray:["uid", tasks.map{return $0.UID} ])
        
        do {
            let coreDataTasks = try managedContext.fetch(fetchRequest)
            for coreDataTask in coreDataTasks {
                managedContext.delete(coreDataTask)
            }
            try managedContext.save()
            completion(nil)
        }
        catch {
            print(error.localizedDescription)
            completion(error)
        }
    }
    
    func removeTaskTypeFromCoreData(type: TaskType, completion: TodooshkaCompletion? ) {
        completion?(nil)
        let fetchRequest = NSFetchRequest<CoreDataTaskType>(entityName: "CoreDataTaskType")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray:["uid", type.UID])
        
        do {
            let coreDataTaskTypes = try managedContext.fetch(fetchRequest)
            for coreDataTaskType in coreDataTaskTypes {
                managedContext.delete(coreDataTaskType)
            }
            try managedContext.save()
        }
        catch {
            print(error.localizedDescription)
            completion?(error)
        }
    }
    
    func removeAllTasksFromCoreData() {
        let fetchRequest = NSFetchRequest<CoreDataTask>(entityName: "CoreDataTask")
        do {
            let coreDataTasks = try managedContext.fetch(fetchRequest)
            for coreDataTask in coreDataTasks {
                managedContext.delete(coreDataTask)
            }
            try managedContext.save()
        }
        catch {
            print(error.localizedDescription)
        }
        return
    }
    
    func removeAllTaskTypesFromCoreData() {
        let fetchRequest = NSFetchRequest<CoreDataTaskType>(entityName: "CoreDataTaskType")
        do {
            let coreDataTaskTypes = try managedContext.fetch(fetchRequest)
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
    
    //MARK: - Firebase - Save
    func saveTaskToFirebase(task: Task, completion: TodooshkaCompletion? ) {
        completion?(nil)
        guard let user = Auth.auth().currentUser else { return }
        let values = ["text": task.text,
                      "type": task.type,
                      "status": task.status.rawValue,
                      "description": task.description,
                      "createdTimeIntervalSince1970": task.createdTimeIntervalSince1970,
                      "closedTimeIntervalSince1970": task.closedTimeIntervalSince1970,
                      "lastModifiedTimeIntervalSince1970": task.lastUpdateDateTime
        ] as [String : Any]
        
        TASKS_REF.child(user.uid).child(task.UID).updateChildValues(values) { error, ref in
            if let error = error {
                print("Ошибка с этим вашим интернетом",error.localizedDescription)
                completion?(error)
            }
        }
    }
    
    func saveTasksToFirebase(tasks: [Task], completion: TodooshkaCompletion? ) {

        guard let user = Auth.auth().currentUser else { return }
        if tasks.isEmpty {
            completion?(TodooshkaError.error("Пустой массив"))
            return
        }
        let dictionary = Dictionary<String, Any?>(uniqueKeysWithValues: tasks.map{ ($0.UID, [
            "text": $0.text,
            "type": $0.type,
            "status": $0.status.rawValue,
            "description": $0.description,
            "createdTimeIntervalSince1970": $0.createdTimeIntervalSince1970,
            "closedTimeIntervalSince1970": $0.closedTimeIntervalSince1970,
            "lastModifiedTimeIntervalSince1970": $0.lastUpdateDateTime
        ]) })
        
        TASKS_REF.child(user.uid).updateChildValues(dictionary) { error, ref in
            if let error = error {
                completion?(error)
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func saveTaskTypeToFirebase(type: TaskType, completion: TodooshkaCompletion? ) {
        completion?(nil)
        guard let user = Auth.auth().currentUser else { return }
        let values = ["text": type.text,
                      "systemImageName": type.systemImageName,
                      "orderNumber": type.orderNumber
        ] as [String : Any]
        
        TASK_TYPES_REF.child(user.uid).child(type.UID).updateChildValues(values) { error, ref in
            if let error = error {
                print("Ошибка с этим вашим интернетом",error.localizedDescription)
                completion?(error)
            }
        }
    }
    
    func saveTaskTypesToFirebase(types: [TaskType], completion: TodooshkaCompletion? ) {
        completion?(nil)
        guard let user = Auth.auth().currentUser else { return }
        let dictionary = Dictionary<String, Any?>(uniqueKeysWithValues: types.map{ ($0.UID, [
            "text": $0.text,
            "systemImageName": $0.systemImageName,
            "orderNumber": $0.orderNumber
        ]) })
        
        TASK_TYPES_REF.child(user.uid).updateChildValues(dictionary)
        
      
    }
    
    //MARK: - Firebase - Remove
    func removeTaskFromFirebase(task: Task, completion: TodooshkaCompletion?) {
        guard let user = Auth.auth().currentUser else { return }
        TASKS_REF.child(user.uid).child(task.UID).removeValue { error, ref in
            if let error = error {
                print(error.localizedDescription)
                completion?(error)
            }
        }
    }
    
    func removeTasksFromFirebase(tasks: [Task], completion: TodooshkaCompletion?) {
        completion?(nil)
        guard let user = Auth.auth().currentUser else { return }
        let dictionary = Dictionary<String, Any?>(uniqueKeysWithValues: tasks.map{ ($0.UID, nil) })
        TASKS_REF.child(user.uid).updateChildValues(dictionary) { error, ref in
            if let error = error {
                print(error.localizedDescription)
                completion?(error)
            }
        }
    }
    
    func removeTaskTypeFromFirebase(type: TaskType, completion: TodooshkaCompletion?) {
        guard let user = Auth.auth().currentUser else { return }
        TASK_TYPES_REF.child(user.uid).child(type.UID).removeValue { error, ref in
            if let error = error {
                print(error.localizedDescription)
                completion?(error)
            }
        }
    }
    
    
    
}
