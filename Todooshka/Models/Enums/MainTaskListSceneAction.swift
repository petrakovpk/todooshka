//
//  MainTaskListSceneAction.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.04.2022.
//

enum ActionStatus {
  case ReadyToRun
  case Running
  case Completed
}

struct MainTaskListSceneAction: Equatable {
  let UID: String
  let action: SceneAction
  let status: ActionStatus
  
  // MARK: - Equatable
  static func == (lhs: MainTaskListSceneAction, rhs: MainTaskListSceneAction) -> Bool {
    lhs.UID == rhs.UID
  }
}
