//
//  AppServices.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

struct AppServices: HasPreferencesService {
    let preferencesService: PreferencesService
    let networkAuthService: NetworkAuthService
    let networkDatabaseService: NetworkDatabaseService
    let coreDataService: CoreDataService
}
