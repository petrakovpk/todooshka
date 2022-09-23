//
//  AppServices.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

struct AppServices: HasActionService, HasPreferencesService, HasDataService, HasTabBarService {
  let actionService: ActionService
  let dataService: DataService
  let preferencesService: PreferencesService
  let tabBarService: TabBarService
}
