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
      
      guard let action = actions[safe: index],
            action != node.action else { continue }
      
      print("1234", index, node.action, action)
      
      switch (node.action, action) {
      case (.Init, .NoCracks):
        node.show(state: .NoCracks, withAnimation: false , completion: nil)
        node.action = action
        continue

      case (.Init, .Crack(let style)):
        node.show(state: .Crack(style: style), withAnimation: false, completion: nil)
        node.action = action
        continue

      case (.Hide, .NoCracks):
        node.show(state: .NoCracks, withAnimation: true , completion: nil)
        node.action = action
        continue

      case (.Hide, .Crack(let style)):
        node.show(state: .Crack(style: style), withAnimation: true, completion: nil)
        node.action = action
        continue

      case (.Crack(_), .NoCracks):
        node.repair()
        node.action = action
        continue

      case (.NoCracks, .Crack(let style)):
        node.crack(completion: { self.hatch(level: node.level, style: style) })
        node.action = action
        continue

      case (_, .Hide):
        node.hide()
        node.action = action
        continue

      default:
        continue
      }
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
  

}
