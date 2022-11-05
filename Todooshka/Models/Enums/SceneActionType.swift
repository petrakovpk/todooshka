//
//  SceneActionType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.05.2022.
//

import Foundation

enum RemovingEggType {
  case broken
  case new
}

enum BirdMovement {
  case running
  case sitting
}

// Экран с задачами
enum NestSceneActionType {
  case add(state: EggActionType)
  case hatch(typeUID: String)
  case remove(removingEggType: RemovingEggType)
}

// Экран с календарем
enum BranchSceneActionType {
  case add(movement: BirdMovement, birds: [Bird], typeUID: String, withDelay: Bool)
  case removeAllBirds
}
