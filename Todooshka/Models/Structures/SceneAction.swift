//
//  SceneAction.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.04.2022.
//

struct NestSceneAction: Equatable {
  // MARK: - Properties
  let UID: String
  let action: NestSceneActionType

  // MARK: - Equatable
  static func == (lhs: NestSceneAction, rhs: NestSceneAction) -> Bool {
    lhs.UID == rhs.UID
  }
}

struct BranchSceneAction: Equatable {
  // MARK: - Properties
  let UID: String
  let action: BranchSceneActionType

  // MARK: - Equatable
  static func == (lhs: BranchSceneAction, rhs: BranchSceneAction) -> Bool {
    lhs.UID == rhs.UID
  }
}
