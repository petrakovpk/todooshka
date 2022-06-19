//
//  SettingsType.swift
//  Todooshka
//
//  Created by Pavel Petakov on 18.06.2022.
//

enum SettingsType {
  // auth
  case logInIsRequired
  case logOutIsRequired
  case removeAccountIsRequired
  // load
  case saveDataIsRequired
  case loadDataIsRequired
  // deleted
  case deletedTaskListIsRequired
  case deletedTaskTypeListIsRequired
}
