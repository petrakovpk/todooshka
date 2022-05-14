//
//  SceneAction.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.05.2022.
//

enum SceneAction {
  
  case BrokeTheEggWithoutBird(egg: Egg)
  case BrokeTheEggAndBornTheBirdAndSendTheBirdWalkToTheRight(egg: Egg)
  case CreateTheEgg(egg: Egg, withAnimation: Bool)
  case ChangeEggClyde(egg: Egg)
  case CrackTheEgg(egg: Egg)
  case HardCrackTheEgg(egg: Egg)
  
  var runOrder: Int {
    switch self {
    case .BrokeTheEggWithoutBird(_):
      return 0
    case .CreateTheEgg(_,_):
      return 1
    case .ChangeEggClyde(_):
      return 2
    case .CrackTheEgg(_):
      return 3
    case .HardCrackTheEgg(_):
      return 4
    case .BrokeTheEggAndBornTheBirdAndSendTheBirdWalkToTheRight(_):
      return 5
    }
  }
}
