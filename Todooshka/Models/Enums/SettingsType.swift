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
//  case loadDataIsRequired
  // deleted
  case deletedTaskListIsRequired
  case deletedTaskTypeListIsRequired
  // help
  case askSupport
  // security
  case removeAccountIsRequired
}
