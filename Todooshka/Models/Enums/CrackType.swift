//
//  EggState.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 25.03.2022.
//

enum CrackType: String {
  
  case NoCrack = "NoCrack"
  case OneCrack = "OneCrack"
  case ThreeCracks = "ThreeCracks"
  
  // imageName
  var stringForImage: String {
    switch self {
    case .NoCrack:
      return "без_трещин"
    case .OneCrack:
      return "одна_трещина"
    case .ThreeCracks:
      return "три_трещины"
    }
  }
}
