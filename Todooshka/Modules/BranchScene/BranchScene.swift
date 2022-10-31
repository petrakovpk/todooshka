//
//  BranchScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 26.11.2021.
//

import UIKit
import SpriteKit

class BranchScene: SKScene {
  
  // MARK: - Private
  private var actions: [BirdActionType] = [.Init, .Init, .Init, .Init, .Init, .Init, .Init]
  private var SKBirdNodes: [SKBirdNode] = []
  
  // MARK: - UI Nodes
  private let background: SKSpriteNode = {
    let node = SKSpriteNode()
    node.xScale = Style.Scene.scale * 1.5
    node.yScale = Style.Scene.scale * 1.5
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
        SKBirdNode(level: 1, style: .Simple),
        SKBirdNode(level: 2, style: .Simple),
        SKBirdNode(level: 3, style: .Simple),
        SKBirdNode(level: 4, style: .Simple),
        SKBirdNode(level: 5, style: .Simple),
        SKBirdNode(level: 6, style: .Simple),
        SKBirdNode(level: 7, style: .Simple)
      ]
      
      for node in SKBirdNodes {
        addChild(node)
        node.position = Settings.Birds.BranchPosition[node.level] ?? .zero
      }
    }
  }
  
  // MARK: - BackgroundNode
  func setup(with backgroundImage: UIImage) {
    let texture = SKTexture(image: backgroundImage)
    let action = SKAction.setTexture(texture, resize: false)
    background.run(action)
  }
  
  func setup(with actions: [BirdActionType]) {
    self.actions = actions
  }
  
  // MARK: - DataSource
    func reloadData() {
      
      let hiddenBirds = SKBirdNodes.filter{ $0.action == .Hide }
      
      for (index, node) in SKBirdNodes.enumerated() {
        
        guard let action = actions[safe: index] else { return }
        
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
        for bird in SKBirdNodes {
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
