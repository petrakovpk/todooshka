//
//  SettingsType.swift
//  Todooshka
//
//  Created by Pavel Petakov on 18.06.2022.
//

enum SettingsType {
  // auth
  case logInIsRequired
  case userProfileIsRequiared
  // sync
  case syncDataIsRequired
  // delete
  case deleteThemeIsRequired
  // deleted
  case deletedTaskListIsRequired
  case deletedTaskTypeListIsRequired
  // help
  case supportIsRequired
  // verification
  case sendForVerificationIsRequired
}
