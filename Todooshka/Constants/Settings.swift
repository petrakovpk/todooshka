//
//  Settings.swift
//  Todooshka
//
//  Created by Pavel Petakov on 01.09.2022.
//

import CoreGraphics

struct Settings {
  struct Birds {
    static let NestPosition: [Int: CGPoint] = [
      1: CGPoint(x: -10 - 30, y: 20),
      2: CGPoint(x: -10 + 26, y: 20),
      3: CGPoint(x: -10 + 80, y: -10),
      4: CGPoint(x: -10 + 48, y: -30),
      5: CGPoint(x: -10, y: -40),
      6: CGPoint(x: -10 - 50, y: -30),
      7: CGPoint(x: -10 - 90, y: -5)
    ]

    static let BranchPosition: [Int: CGPoint] = [
      1: CGPoint(x: 150, y: 0),
      2: CGPoint(x: -150, y: 0),
      3: CGPoint(x: 100, y: 0),
      4: CGPoint(x: -100, y: 0),
      5: CGPoint(x: 50, y: 0),
      6: CGPoint(x: -60, y: 0),
      7: CGPoint(x: 0, y: 0)
    ]
  }

  struct Eggs {
    static let NestPosition: [Int: CGPoint] = [
      1: CGPoint(x: -10 - 30, y: 20),
      2: CGPoint(x: -10 + 26, y: 20),
      3: CGPoint(x: -10 + 80, y: -10),
      4: CGPoint(x: -10 + 48, y: -30),
      5: CGPoint(x: -10, y: -40),
      6: CGPoint(x: -10 - 50, y: -30),
      7: CGPoint(x: -10 - 90, y: -5)
    ]
  }
}
