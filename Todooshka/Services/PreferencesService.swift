//
//  PreferencesService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import CoreData
import Firebase
import RxRelay
import RxSwift

protocol HasPreferencesService {
  var preferencesService: PreferencesService { get }
}

class PreferencesService {
  
  
  
  let midFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "dd MMM"
    return formatter
  }()
  
  let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "dd MMMM yyyy"
    formatter.timeZone = TimeZone.current
    return formatter
  }()
  
  let scrollToCurrentMonthTrigger = BehaviorRelay<(trigger: Bool, withAnimation: Bool)>(value: (false, false))
  
  var isOnboardingCompleted: Bool {
    UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
  }
  
  var applicationDocumentsDirectory: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
  }
  
  
  
  
  init() {
    
    // STUPID MIGRATION
//    do {
//
//      let coreDataTaskTypes = try context.fetch(CoreDataTaskType.fetchRequest())
//      let coreDataTasks = try context.fetch(CoreDataTask.fetchRequest())
//
//      for coreDataTaskType in coreDataTaskTypes {
//        print("1234", coreDataTaskType.value(forKey: "imageColorHex") )
//        print("1234", coreDataTaskType.value(forKey: "imageName") )
//        print("1234", coreDataTaskType.value(forKey: "ordernumber") )
//        print("1234", coreDataTaskType.value(forKey: "status") )
//        print("1234", coreDataTaskType.value(forKey: "text") )
//        print("1234", coreDataTaskType.value(forKey: "uid") )
//
//      }
//
//
      
  //    for coreDataTask in coreDataTasks {
//        guard let uid = coreDataTask.value(forKey: "uid") as? String else { continue }
//                
//        let task = Task(UID: <#T##String#>, text: <#T##String#>, description: <#T##String?#>, kindOfTaskUID: <#T##String#>, status: <#T##TaskStatus#>, created: <#T##Date#>, closed: <#T##Date?#>, planned: <#T##Date?#>)
 //     }
//
//      if let task = result.first {
//        print("1234", task.value(forKey: "closedTimeIntervalSince1970") )
//        print("1234", task.value(forKey: "createdTimeIntervalSince1970") )
//        print("1234", task.value(forKey: "lastmodifiedtimeintervalsince1970") )
//        print("1234", task.value(forKey: "longText") )
//        print("1234", task.value(forKey: "orderNumber") )
//        print("1234", task.value(forKey: "status") )
//        print("1234", task.value(forKey: "text") )
//        print("1234", task.value(forKey: "type") )
//        print("1234", task.value(forKey: "uid") )
//        print("1234", task.value(forKey: "userUID") )
//      }
      

//    } catch {
//      print("1234", error.localizedDescription)
//    }

  }
  
  func migrateFromV1toV2() {
    let oldModelUrl = Bundle.main.url(forResource: "Todooshka.momd/Todooshka", withExtension: "mom")!
    let newModeUrl = Bundle.main.url(forResource: "Todooshka.momd/Todooshka v2", withExtension: "mom")!
    
    let oldManagedObjectModel = NSManagedObjectModel.init(contentsOf: oldModelUrl)
    let newManagedObjectModel = NSManagedObjectModel.init(contentsOf: newModeUrl)
    
    let oldUrl = self.applicationDocumentsDirectory.appendingPathComponent("Todooshka.sqlite")
    let newUrl = self.applicationDocumentsDirectory.appendingPathComponent("Todooshka v2.sqlite")
    
    let mappingModel = NSMappingModel(from: nil, forSourceModel: oldManagedObjectModel, destinationModel: newManagedObjectModel)
    let migrationManager = NSMigrationManager(sourceModel: oldManagedObjectModel!, destinationModel: newManagedObjectModel!)
    
    do {
      try migrationManager.migrateStore(
          from: oldUrl,
          sourceType: NSSQLiteStoreType,
          options: nil,
          with: mappingModel,
          toDestinationURL: newUrl,
          destinationType: NSSQLiteStoreType,
          destinationOptions: nil)
      
    } catch {
      
    }
    
  }
  
 
  
}
