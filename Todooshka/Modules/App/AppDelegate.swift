//
//  AppDelegate.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import CoreData
import Firebase
import GoogleSignIn
import Lottie
import SwifterSwift
import UIKit
import YandexMobileMetrica


@main
class AppDelegate: UIResponder, UIApplicationDelegate  {
  
  @available(iOS 9.0, *)
  func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }
  
  var applicationDocumentsDirectory: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Initializing the AppMetrica SDK.
    let configuration = YMMYandexMetricaConfiguration.init(apiKey: "36538b4c-0eb1-408f-b8e5-c8786424d033")
    configuration?.sessionTimeout = 15
    YMMYandexMetrica.activate(with: configuration!)
    
    FirebaseApp.configure()
    
    Auth.auth().languageCode = "ru"
    Database.database().isPersistenceEnabled = true

#if DEBUG
    UIApplication.shared.isIdleTimerDisabled = true
#endif
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
  
  // MARK: - Core Data stack
  
  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "Todooshka")
    
    /*add necessary support for migration*/
    let description = NSPersistentStoreDescription()
//    description.shouldMigrateStoreAutomatically = false
//    description.shouldInferMappingModelAutomatically = false
//    container.persistentStoreDescriptions =  [description]
    /*add necessary support for migration*/
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      } else {

      }
    })
    return container
  }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  func generateOldData() {
    let oldModelUrl = Bundle.main.url(forResource: "Todooshka.momd/Todooshka", withExtension: "mom")!
    let oldManagedObjectModel = NSManagedObjectModel.init(contentsOf: oldModelUrl)

    let coordinator = NSPersistentStoreCoordinator.init(managedObjectModel: oldManagedObjectModel!)
    let url = self.applicationDocumentsDirectory.appendingPathComponent("Todooshka.sqlite")

    try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    
    let coreDataTask = NSEntityDescription.insertNewObject(forEntityName: "CoreDataTask", into: managedObjectContext)
    coreDataTask.setValue(UUID().uuidString, forKey: "uid")
    coreDataTask.setValue("HELLO WORLD!!", forKey: "text")
    coreDataTask.setValue(Date().timeIntervalSince1970, forKey: "createdTimeIntervalSince1970")
    coreDataTask.setValue(Date().timeIntervalSince1970, forKey: "lastmodifiedtimeintervalsince1970")
    coreDataTask.setValue("HEEEEYYY", forKey: "longText")
    coreDataTask.setValue(1, forKey: "orderNumber")
    coreDataTask.setValue("InProgress", forKey: "status")
    coreDataTask.setValue("Student", forKey: "type")
    coreDataTask.setValue(Auth.auth().currentUser?.uid, forKey: "userUID")

    do {
      print("1234", coreDataTask)
      try managedObjectContext.save()
    } catch {
      print("1234", error.localizedDescription)
    }
  }
  
}

