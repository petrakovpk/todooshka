//
//  BranchScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 26.11.2021.
//

import UIKit
import SpriteKit

class BranchScene: SKScene {
  
  // MARK: - Public
  
  // MARK: - Private
  private var actions: [Int: BirdActionType] = [1: .Init, 2: .Init, 3: .Init, 4: .Init, 5: .Init, 6: .Init, 7: .Init]
  private var SKBirdNodes: [Int: SKBirdNode] = [:]
  
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
      
      // birds
      SKBirdNodes = [
        1: SKBirdNode(clade: Clade(index: 1), style: .Simple, scenePosition: position),
        2: SKBirdNode(clade: Clade(index: 2), style: .Simple, scenePosition: position),
        3: SKBirdNode(clade: Clade(index: 3), style: .Simple, scenePosition: position),
        4: SKBirdNode(clade: Clade(index: 4), style: .Simple, scenePosition: position),
        5: SKBirdNode(clade: Clade(index: 5), style: .Simple, scenePosition: position),
        6: SKBirdNode(clade: Clade(index: 6), style: .Simple, scenePosition: position),
        7: SKBirdNode(clade: Clade(index: 7), style: .Simple, scenePosition: position)
      ]
      
      for node in SKBirdNodes.values {
        addChild(node)
        node.position = node.branchPosition
      }
    }
  }
  
  // MARK: - BackgroundNode
  func setup(with backgroundImage: UIImage) {
    let texture = SKTexture(image: backgroundImage)
    let action = SKAction.setTexture(texture, resize: false)
    background.run(action)
  }
  
  func setup(with actions: [Int: BirdActionType]) {
    self.actions = actions
  }
  
  func setup(with birds: [Bird]) {
  //  self.birds = birds
  }
  
  // MARK: - DataSource
    func reloadData() {
      
      let hiddenBirds = SKBirdNodes.filter{ $0.value.action == .Hide }
      
      for (index, node) in SKBirdNodes {
        guard let action = actions[index] else { return }
        
        switch (node.action, action) {
        case (.Init, .Sitting(let newStyle, _)):
          node.changeStyle(style: newStyle, withDelay: false)
        
        case (.Hide, .Sitting(let newStyle, _)):
          node.changeStyle(style: newStyle, withDelay: hiddenBirds.count != 7 )
        
        case (.Sitting(let oldStyle, let oldClosed), .Sitting(let newStyle, let newClosed)):
          if Calendar.current.isDate(oldClosed, inSameDayAs: newClosed) == false || oldStyle != newStyle {
            node.changeStyle(style: newStyle, withDelay: true)
          }
          
        case (_, .Hide):
          node.hide()
        default:
          continue
        }
        
        node.action = action
      }
    }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let location = touch.location(in: self)
      let touchedNode = self.nodes(at: location)
      for node in touchedNode {
        for bird in SKBirdNodes.values {
          if node == bird {
            if bird.wingsIsUp {
              bird.wingsIsUp = false
              bird.dowsWings()
            } else {
              bird.wingsIsUp = true
              bird.upWings()
            }
          }
        }
      }
    }
  }
}
