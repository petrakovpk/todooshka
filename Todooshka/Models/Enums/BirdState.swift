//
//  BirdState.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.05.2022.
//

enum BirdState: String {
  case Normal = "Normal"
  case ClosedEyes = "ClosedEyes"
  case RaisedWings = "RaisedWings"
  case LeftLegForward = "LeftLegForward"
  case RightLegForward = "RightLegForward"
  
  var imageName: String {
    switch self {
    case .Normal:
      return "статика"
    case .ClosedEyes:
      return "закрытые_глаза"
    case .RaisedWings:
      return "взмах_крыла"
    case .LeftLegForward:
      return "левая_нога_вперед"
    case .RightLegForward :
      return "правая_нога_вперед"
    }
  }
}

