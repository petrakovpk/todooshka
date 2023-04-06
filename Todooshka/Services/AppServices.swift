//
//  AppServices.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

struct AppServices: HasTaskAPIService, HasUserAPIService { //HasAuthService, HasActionService, HasPreferencesService, HasDataService, HasTabBarService, HasMigrationService {
//  let authService: AuthService
//  let actionService: ActionService
//  let dataService: DataService
//  let migrationService: MigrationService
//  let preferencesService: PreferencesService
//  let tabBarService: TabBarService
  var taskAPIService: TaskAPIService
  var userAPIService: UserAPIService
}

