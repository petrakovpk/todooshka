//
//  NestScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.11.2021.
//

import UIKit
import SpriteKit

class NestScene: SKScene {
  
  // MARK: - Public

  
  // MARK: - Private
  private var actions: [Int: EggActionType] = [1: .Init, 2: .Init, 3: .Init, 4: .Init, 5: .Init, 6: .Init, 7: .Init]
  private var birds: [Bird] = []
  private var SKEggNodes: [Int: SKEggNode] = [:]
  
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
        1: SKEggNode(index: 1, parentPosition: position),
        2: SKEggNode(index: 2, parentPosition: position),
        3: SKEggNode(index: 3, parentPosition: position),
        4: SKEggNode(index: 4, parentPosition: position),
        5: SKEggNode(index: 5, parentPosition: position),
        6: SKEggNode(index: 6, parentPosition: position),
        7: SKEggNode(index: 7, parentPosition: position)
      ]
      
      for node in SKEggNodes.values {
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
  
  func setup(with actions: [Int: EggActionType]) {
    self.actions = actions
  }
  
  func setup(with birds: [Bird]) {
    self.birds = birds
  }
  
  // MARK: - DataSource
  func reloadData() {
    for (index, node) in SKEggNodes {
      guard let action = actions[index] else { continue }
      
      switch (node.action, action) {
      case (.Init, .NoCracks):
        node.show(state: .NoCracks, withAnimation: false , completion: nil)

      case (.Init, .Crack(let typeUID)):
        node.show(state: .Crack(typeUID: typeUID), withAnimation: false, completion: nil)

      case (.Hide, .NoCracks):
        node.show(state: .NoCracks, withAnimation: true , completion: nil)

      case (.Hide, .Crack(let typeUID)):
        node.show(state: .Crack(typeUID: typeUID), withAnimation: true, completion: nil)

      case (.Crack(_), .NoCracks):
        node.repair()

      case (.NoCracks, .Crack(let typeUID)):
        node.crack(completion: { self.hatch(index: index, typeUID: typeUID) })

      case (_, .Hide):
        node.hide()

      default:
        continue
      }
      
      node.action = action
    }
  }
  
  func hatch(index: Int, typeUID: String) {
    
    guard let bird = birds.first(where: { $0.clade.index == index && $0.kindsOfTaskUID.contains{ $0 == typeUID }}) else { return }
    
    let node = SKBirdNode(clade: Clade(index: index), style: bird.style, scenePosition: position)
    
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
    
    for node in SKEggNodes.values where node.isCracking == true {
      node.removeAllActions()
      node.forceCrack()
      node.isCracking = false 
    }
    
    for node in children where node.name == "Bird" {
      node.removeFromParent()
    }

  }
  
}
