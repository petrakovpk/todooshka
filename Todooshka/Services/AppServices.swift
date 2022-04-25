//
//  AppServices.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

struct AppServices: HasBirdService, HasPreferencesService, HasTasksService, HasTypesService, HasPointService, HasBirdTypeService {
  let birdService: BirdService
  let birdTypeService: BirdTypeService
  let pointService: PointService
  let preferencesService: PreferencesService
  let tasksService: TasksService
  let typesService: TypesService
}
