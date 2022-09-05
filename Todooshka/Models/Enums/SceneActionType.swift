//
//  SceneActionType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.05.2022.
//

import Foundation

//enum AddingEggType: Equatable {
//  case Cracked
//  case NotCracked
//}

enum RemovingEggType {
  case Broken
  case New
}

enum BirdMovement {
  case Running, Sitting
}

// Экран с задачами
enum NestSceneActionType {
  case Add(state: EggActionType)
  case Hatch(typeUID: String)
  case Remove(removingEggType: RemovingEggType)
}

// Экран с календарем
enum BranchSceneActionType {
  case Add(movement: BirdMovement, birds: [Bird], typeUID: String, withDelay: Bool)
  case RemoveAllBirds
}
