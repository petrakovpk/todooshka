//
//  MainSceneView.swift
//  DragoDo
//
//  Created by Pavel Petakov on 26.01.2023.
//

import UIKit
import SpriteKit

class MainScene: SKScene {
  private let leftSceneNode: SKSpriteNode = {
    let node = SKSpriteNode()
    let texture = SKTexture(image: UIImage(named: "день01") ?? UIImage())
    let action = SKAction.setTexture(texture, resize: false)
    node.run(action)
    node.xScale = Style.Scene.scale
    node.yScale = Style.Scene.scale
    node.name = "leftSceneNode"
    return node
  }()
  
  private let rightSceneNode: SKSpriteNode = {
    let node = SKSpriteNode()
    let texture = SKTexture(image: UIImage(named: "день02") ?? UIImage())
    let action = SKAction.setTexture(texture, resize: false)
    node.run(action)
    node.xScale = Style.Scene.scale
    node.yScale = Style.Scene.scale
    node.name = "leftSceneNode"
    return node
  }()

  // MARK: - Lifecycle
  override func didMove(to view: SKView) {
    if let scene = scene {
      scene.size = view.size
      
      leftSceneNode.position = .zero
      leftSceneNode.size = view.size
      
      rightSceneNode.position = CGPoint(x: view.width, y: 0)
      rightSceneNode.size = view.size
      
      addChild(leftSceneNode)
      addChild(rightSceneNode)
      
    }
    
  }
    
//    if let scene = scene {
//      scene.size = view.size
//      scene.backgroundColor = .clear
//
//      addChild(background)
//      addChild(backgroundBottom)
//
//      background.position = CGPoint(x: position.x + 40, y: position.y)
//      backgroundBottom.position = background.position
//
//      SKEggNodes = [
//        SKEggNode(level: 1),
//        SKEggNode(level: 2),
//        SKEggNode(level: 3),
//        SKEggNode(level: 4),
//        SKEggNode(level: 5),
//        SKEggNode(level: 6),
//        SKEggNode(level: 7)
//      ]
//
//      for node in SKEggNodes {
//        addChild(node)
//        node.position = Settings.Eggs.NestPosition[node.level] ?? .zero
//      }
//    }
  public func moveToTheLeftScene() {
    let moveLeftSceneNode = SKAction.move(to: CGPoint(x: -380, y: 0), duration: 0.5)
    let moveRightSceneNode = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.5)
    leftSceneNode.run(moveLeftSceneNode)
    rightSceneNode.run(moveRightSceneNode)
  }
  
  public func moveToTheRightScene() {
    let moveLeftSceneNode = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.5)
    let moveRightSceneNode = SKAction.move(to: CGPoint(x: 380, y: 0), duration: 0.5)
    leftSceneNode.run(moveLeftSceneNode)
    rightSceneNode.run(moveRightSceneNode)
  }

  // MARK: - Setup
//  func setup(withBackground image: UIImage) {
//    let texture = SKTexture(image: image)
//    let action = SKAction.setTexture(texture, resize: false)
//    background.run(action)
//  }
//
//  func setup(with actions: [EggActionType]) {
//    self.actions = actions
//  }

  // MARK: - DataSource
//  func reloadData() {
//    for (index, node) in SKEggNodes.enumerated() {
//      guard
//        let action = actions[safe: index],
//        action != node.action
//      else { continue }
//
//      switch (node.action, action) {
//      case (.create, .noCracks):
//        node.show(state: .noCracks, withAnimation: false, completion: nil)
//        node.action = action
//        continue
//
//      case (.create, .crack(let style)):
//        node.show(state: .crack(style: style), withAnimation: false, completion: nil)
//        node.action = action
//        continue
//
//      case (.hide, .noCracks):
//        node.show(state: .noCracks, withAnimation: true, completion: nil)
//        node.action = action
//        continue
//
//      case (.hide, .crack(let style)):
//        node.show(state: .crack(style: style), withAnimation: true, completion: nil)
//        node.action = action
//        continue
//
//      case (.crack, .noCracks):
//        node.repair()
//        node.action = action
//        continue
//
//      case (.noCracks, .crack(let style)):
//        node.crack(completion: { self.hatch(level: node.level, style: style) })
//        node.action = action
//        continue
//
//      case (_, .hide):
//        node.hide()
//        node.action = action
//        continue
//
//      default:
//        continue
//      }
//    }
//  }

//  func hatch(level: Int, style: BirdStyle) {
//    let node = SKBirdNode(level: level, style: style)
//
//    // adding
//    addChild(node)
//    node.position = Settings.Birds.NestPosition[node.level] ?? .zero
//
//    // node
//   // node.position = node.nestPosition
//    node.runFromNest {
//     node.removeFromParent()
//    }
//  }
}

