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

struct SceneAction: Equatable {
  
  let UID: String
  let action: SceneActionType

  // MARK: - Equatable
  static func == (lhs: SceneAction, rhs: SceneAction) -> Bool {
    lhs.UID == rhs.UID
  }
}
