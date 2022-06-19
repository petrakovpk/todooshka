//
//  SceneActionType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.05.2022.
//

import Foundation

enum SceneActionType {
  
  // MainTaskListScene
  case CreateTheEgg(withAnimation: Bool)
  case HatchTheBird(birds: [Bird])
  case RemoveTheEgg
  
  // UserProfileTaskListScene
  case RunTheBird(birds: [Bird], created: Date)
  case RemoveLastBird
}
