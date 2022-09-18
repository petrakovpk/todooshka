//
//  AppServices.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

struct AppServices: HasActionService, HasBirdService, HasPreferencesService, HasDataService, HasGameCurrencyService, HasBirdTypeService, HasTabBarService {
  let actionService: ActionService
  let birdService: BirdService
  let birdTypeService: BirdTypeService
  let dataService: DataService
  let gameCurrencyService: GameCurrencyService
  let preferencesService: PreferencesService
  let tabBarService: TabBarService
}
