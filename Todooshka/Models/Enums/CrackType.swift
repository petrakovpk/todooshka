//
//  EggState.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 25.03.2022.
//

enum CrackType: String {
  case noCrack = "noCrack"
  case oneCrack = "oneCrack"
  case threeCracks = "threeCracks"

  // imageName
  var stringForImage: String {
    switch self {
    case .noCrack:
      return "без_трещин"
    case .oneCrack:
      return "одна_трещина"
    case .threeCracks:
      return "три_трещины"
    }
  }
}
