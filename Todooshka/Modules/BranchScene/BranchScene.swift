//
//  BranchScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 26.11.2021.
//

import UIKit
import SpriteKit

enum BirdSceneStatus {
  case NoBird, Sitting
}

class BranchScene: SKScene {
  
  // MARK: - Data
  private var data: [Int: BirdSceneStatus] = [1: .NoBird, 2: .NoBird, 3: .NoBird, 4: .NoBird, 5: .NoBird, 6: .NoBird, 7: .NoBird]
  
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
    }
  }
  
  // MARK: - BackgroundNode
  func setup(with backgroundImage: UIImage) {
    let texture = SKTexture(image: backgroundImage)
    let action = SKAction.setTexture(texture, resize: false)
    background.run(action)
  }
  
  // MARK: - Actions
  func run(actions: [BranchSceneAction]) {
    actions.forEach { action in
      switch action.action {
      case .AddTheRunningBird(let birds, let typeUID, let withDelay):
        self.addTheRunningBird(birds: birds, typeUID: typeUID, withDelay: withDelay)
      case .AddTheSittingBird(let typeUID):
        return
      }
    }
  }
  
  func addTheRunningBird(birds: [Bird], typeUID: String, withDelay: Bool) {
 
    guard let birdN = data.filter({ $0.value == .NoBird }).min(by: { $0.key < $1.key })?.key,
          let bird = birds.first(where: { $0.clade.birdN == birdN && $0.typesUID.contains{ $0 == typeUID }}),
          let clade = Clade(birdN: birdN) else { return }
    
    let node = SKBirdNode(clade: clade, style: bird.style)
    
    // data
    data[birdN] = .Sitting
    
    // adding
    addChild(node)
    
    // node
    node.position = CGPoint(x: -1 * UIScreen.main.bounds.width / 2, y: position.y)
    
    // action
    node.run(withDelay: withDelay, toPosition: CGPoint(x: position.x + node.sittingPosition.x, y: position.y + node.sittingPosition.y)) {
      
    }
    
  }
}
