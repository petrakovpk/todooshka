//
//  UserProfileScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 26.11.2021.
//

import UIKit
import SpriteKit

class UserProfileScene: SKScene {

  // MARK: - Properties
  private var background: SKSpriteNode!
//  private let dragon1 = SKSpriteNode(imageNamed: "dragon")
//  private let dragon2 = SKSpriteNode(imageNamed: "dragon")
//  private let dragon3 = SKSpriteNode(imageNamed: "dragon")
//  private let dragon4 = SKSpriteNode(imageNamed: "dragon")
  
  // MARK: - UI Nodes
  override func didMove(to view: SKView) {
    if let scene = scene {
      scene.size = view.size
      background = SKSpriteNode(imageNamed: gerScreenImageName())
      background.size = view.frame.size
      addChild(background)
    }
  }
  
  // MARK: - Setup Nodes
  func setupNodes() {
//    backgroundColor = .white
//
//    let dragonHeight = 150.0
//    let dragonWidth = dragonHeight
//
//    addChild(dragon1)
//    dragon1.size = CGSize(width: dragonWidth, height: dragonHeight)
//    dragon1.position = CGPoint(x: 80, y: -40)
//
//    dragon2.xScale = -1.0;
//    addChild(dragon2)
//    dragon2.size = CGSize(width: dragonWidth, height: dragonHeight)
//    dragon2.position = CGPoint(x: -80, y: -40)
//
//    addChild(dragon3)
//    dragon3.size = CGSize(width: dragonWidth, height: dragonHeight)
//    dragon3.position = CGPoint(x: 220, y: -40)
//
//    dragon4.xScale = -1.0;
//    addChild(dragon4)
//    dragon4.size = CGSize(width: dragonWidth, height: dragonHeight)
//    dragon4.position = CGPoint(x: -220, y: -40)
  }
  
  func gerScreenImageName() -> String {
    switch Date().hour {
    case 0...6:
      return "ночь02"
    case 7...12:
      return "утро02"
    case 13...18:
      return "день02"
    case 19...23:
      return "вечер02"
    default:
      return "вечер02"
    }
  }
  
  public func configureDragons(count: Int) {
//    switch count {
//
//    case 0:
//      dragon1.isHidden = true
//      dragon2.isHidden = true
//      dragon3.isHidden = true
//      dragon4.isHidden = true
//
//    case 1:
//      dragon1.isHidden = false
//      dragon2.isHidden = true
//      dragon3.isHidden = true
//      dragon4.isHidden = true
//
//    case 2:
//      dragon1.isHidden = false
//      dragon2.isHidden = false
//      dragon3.isHidden = true
//      dragon4.isHidden = true
//
//    case 3:
//      dragon1.isHidden = false
//      dragon2.isHidden = false
//      dragon3.isHidden = false
//      dragon4.isHidden = true
//
//    case 4...999 :
//      dragon1.isHidden = false
//      dragon2.isHidden = false
//      dragon3.isHidden = false
//      dragon4.isHidden = false
//
//    default:
//      return
//    }
  }
}
