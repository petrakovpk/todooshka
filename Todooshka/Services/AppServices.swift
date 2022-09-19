//
//  AppServices.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

struct AppServices: HasActionService, HasPreferencesService, HasDataService, HasGameCurrencyService, HasTabBarService {
  let actionService: ActionService
  let dataService: DataService
  let gameCurrencyService: GameCurrencyService
  let preferencesService: PreferencesService
  let tabBarService: TabBarService
}
