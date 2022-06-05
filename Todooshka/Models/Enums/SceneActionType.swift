//
//  SceneActionType.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.05.2022.
//

enum SceneActionType {
  case CreateTheEgg(withAnimation: Bool)
  case HatchTheBird(birds: [Bird])
  case RemoveTheEgg
}
