//
//  SceneActionType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.05.2022.
//

import Foundation

// Экран с задачами
enum NestSceneActionType {
  case AddTheEgg(withAnimation: Bool)
  case HatchTheBird(typeUID: String)
  case RemoveTheEgg
}

// Экран с календарем
enum BranchSceneActionType {
  case AddTheRunningBird(birds: [Bird], typeUID: String, withDelay: Bool)
  case AddTheSittingBird(typeUID: String)
}
