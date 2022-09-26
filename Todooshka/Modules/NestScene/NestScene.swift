//
//  NestScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.11.2021.
//

import UIKit
import SpriteKit

class NestScene: SKScene {
  
  // MARK: - Private
  private var actions: [EggActionType] = [.Init, .Init, .Init, .Init, .Init, .Init, .Init]
  private var SKEggNodes: [SKEggNode] = []
  
  // MARK: - UI Nodes
  private let background: SKSpriteNode = {
    let node = SKSpriteNode()
    node.xScale = Theme.Scene.scale * 1.5
    node.yScale = Theme.Scene.scale * 1.5
    node.name = "background"
    return node
  }()

  // MARK: - Lifecycle
  override func didMove(to view: SKView) {
    if let scene = scene {
      
      // scene
      scene.size = view.size
      scene.backgroundColor = .clear
      
      // adding
      addChild(background)
      
      // background
      background.position = CGPoint(x: position.x + 40, y: position.y)
      
      // nodes
      SKEggNodes = [
        SKEggNode(level: 1, parentPosition: position),
        SKEggNode(level: 2, parentPosition: position),
        SKEggNode(level: 3, parentPosition: position),
        SKEggNode(level: 4, parentPosition: position),
        SKEggNode(level: 5, parentPosition: position),
        SKEggNode(level: 6, parentPosition: position),
        SKEggNode(level: 7, parentPosition: position)
      ]
      
      for node in SKEggNodes {
        addChild(node)
        node.position = node.nestPosition
      }
    }
  }
  
  // MARK: - Setup
  func setup(with backgroundImage: UIImage) {
    let texture = SKTexture(image: backgroundImage)
    let action = SKAction.setTexture(texture, resize: false)
    background.run(action)
  }
  
  func setup(with actions: [EggActionType]) {
    self.actions = actions
  }
  
  // MARK: - DataSource
  func reloadData() {
    for (index, node) in SKEggNodes.enumerated() {
      
      guard let action = actions[safe: index] else { continue }
      
      switch (node.action, action) {
      case (.Init, .NoCracks):
        node.show(state: .NoCracks, withAnimation: false , completion: nil)

      case (.Init, .Crack(let style)):
        node.show(state: .Crack(style: style), withAnimation: false, completion: nil)

      case (.Hide, .NoCracks):
        node.show(state: .NoCracks, withAnimation: true , completion: nil)

      case (.Hide, .Crack(let style)):
        node.show(state: .Crack(style: style), withAnimation: true, completion: nil)

      case (.Crack(_), .NoCracks):
        node.repair()

      case (.NoCracks, .Crack(let style)):
        node.crack(completion: { self.hatch(level: node.level, style: style) })

      case (_, .Hide):
        node.hide()

      default:
        continue
      }
      
      node.action = action
    }
  }
  
  func hatch(level: Int, style: Style) {
    
    let node = SKBirdNode(clade: Clade(level: level), style: style, scenePosition: position)

    // adding
    addChild(node)

    // node
    node.position = node.nestPosition
    node.runFromNest() {
      node.removeFromParent()
    }
  }
  
  // Убираем птиц и крекаем яйца
  func forceUpdate() {
    
    for node in SKEggNodes where node.isCracking == true {
      node.removeAllActions()
      node.forceCrack()
      node.isCracking = false 
    }
    
    for node in children where node.name == "Bird" {
      node.removeFromParent()
    }

  }
  
}
