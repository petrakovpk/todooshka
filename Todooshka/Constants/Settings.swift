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
      1: CGPoint(x: -30, y: 20),
      2: CGPoint(x: 20, y: 20),
      3: CGPoint(x: 70, y: -5),
      4: CGPoint(x: 35, y: -35),
      5: CGPoint(x: -5, y: -40),
      6: CGPoint(x: -45, y: -35),
      7: CGPoint(x: -80, y: -5)
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
      1: CGPoint(x: -30, y: 20),
      2: CGPoint(x: 20, y: 20),
      3: CGPoint(x: 70, y: -5),
      4: CGPoint(x: 35, y: -35),
      5: CGPoint(x: -5, y: -40),
      6: CGPoint(x: -45, y: -35),
      7: CGPoint(x: -80, y: -5)
    ]
  }
}
