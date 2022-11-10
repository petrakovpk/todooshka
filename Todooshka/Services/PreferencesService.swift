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

  var applicationDocumentsDirectory: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
  }

  init() {
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
