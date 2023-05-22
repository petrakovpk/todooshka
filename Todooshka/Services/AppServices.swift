//
//  AppServices.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

struct AppServices: HasTaskAPIService, HasCurrentUserService, HasTemporaryDataService {
  var taskAPIService: TaskAPIService
  var currentUserService: CurrentUserService
  var temporaryDataService: TemporaryDataService
}

