//
//  TaskListScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.11.2021.
//

import UIKit
import SpriteKit

class TaskListScene: SKScene {
  
  // MARK: - Properties
  private var background: SKSpriteNode!
  private var eggs: [Egg] = []
  
  // MARK: - UI Nodes
  override func didMove(to view: SKView) {
    if let scene = scene {
      scene.size = view.size
      backgroundColor = .clear
    }
  }
  
  // MARK: - Public funcs
  func updateBackgroundImage(image: UIImage) {
    let texture = SKTexture(image: image)
    background = SKSpriteNode(texture: texture)
    background.xScale = Constants.Scene.k
    background.yScale = Constants.Scene.k
    addChild(background)
    
  }
  
  func doAction(action: EggAction) {
    switch action {
    case .Create(let egg, let withAnimation):
      if let position = getPositionPoint(positionNum: egg.position) {
        let texture = SKTexture(image: egg.image)
        let node = SKSpriteNode(texture: texture)
        node.name = egg.UID
        node.xScale = Constants.Scene.k
        node.yScale = Constants.Scene.k
        node.position = position
        node.zPosition = CGFloat(egg.position)
        addChild(node)
        eggs.append(egg)
      }
    case .Update(let egg):
      return
    case .Remove(let egg):
      if let node = childNode(withName: egg.UID) {
        node.removeFromParent()
      }
    }
    
  }
  
  func updateEgg(egg: Egg) {
    
  }
  
  func removeEgg(_ egg: Egg) {
    eggs.removeAll(egg)
    for node in children where (name == "egg" && userData?["UID"] as! String == egg.UID) {
      node.removeFromParent()
    }
  }
  
  // MARK: - Helpers
  func getPositionPoint(positionNum: Int) -> CGPoint? {
    switch positionNum {
    case 0:
      return CGPoint(x: position.x - 35, y: position.y + 15)
    case 1:
      return CGPoint(x: position.x - 80, y: position.y + 5)
    case 2:
      return CGPoint(x: position.x + 10, y: position.y + 5)
    case 3:
      return CGPoint(x: position.x - 57, y: position.y - 5)
    case 4:
      return CGPoint(x: position.x - 13, y: position.y - 5)
    case 5:
      return CGPoint(x: position.x - 35, y: position.y - 10)
    default:
      return nil
    }
  }
}
