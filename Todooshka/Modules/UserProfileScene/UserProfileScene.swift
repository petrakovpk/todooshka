//
//  UserProfileScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 26.11.2021.
//

import UIKit
import SpriteKit

class UserProfileScene: SKScene {

  // MARK: - UI Nodes
  override func didMove(to view: SKView) {
    if let scene = scene {
      scene.size = view.size
      backgroundColor = .clear
    }
  }
  
  // MARK: - BackgroundNode
  func setupBackgroundNode(image: UIImage) {
    let texture = SKTexture(image: image)
    
    if let node = childNode(withName: "background") {
      let action = SKAction.setTexture(texture, resize: false)
      node.run(action)
    } else {
      let node = SKSpriteNode(texture: texture)
      node.xScale = Theme.Scene.scale * 1.5
      node.yScale = Theme.Scene.scale * 1.5
      node.name = "background"
      node.position = CGPoint(x: self.position.x + 40, y: self.position.y)
      addChild(node)
    }
  }
  
  // MARK: - Actions
  func runActions(actions: [SceneAction]) {
    actions.forEach { action in
      switch action.action {
      case .RunTheBird(let birds, let created):
        runTheBird(birds: birds, created: created)
      default:
        return
      }
    }
  }
  
  func runTheBird(birds: [Bird], created: Date) {
    let index = getFirstBirdIndex()
    guard let birdNormalImage = self.getBirdImage(index: index, birds: birds, state: .Normal) else { return }
    guard let birdLeftLegForwardImage = self.getBirdImage(index: index, birds: birds, state: .LeftLegForward) else { return }
    guard let birdRightLegForwardImage = self.getBirdImage(index: index, birds: birds, state: .RightLegForward) else { return }
    
    let birdNormalTexture = SKTexture(image: birdNormalImage)
    let birdLeftLegForwardTexture = SKTexture(image: birdLeftLegForwardImage)
    let birdRightLegForwardTexture = SKTexture(image: birdRightLegForwardImage)
    
    let birdNode = SKSpriteNode(texture: birdRightLegForwardTexture)
    
    let animateAction = SKAction.repeatForever(SKAction.animate(with: [birdLeftLegForwardTexture, birdRightLegForwardTexture], timePerFrame: 0.3, resize: true, restore: false))
    
    let velocity = 91.0
    let space = getBirdPosition(index: index).x - (scene?.frame.origin.x)!
    let duration = space / velocity
    
    let moveAction = SKAction.move(to: getBirdPosition(index: index), duration: duration)
    
    let shouldWait = (Date().timeIntervalSince1970 - created.timeIntervalSince1970) < 4
    
    let fadeIn = SKAction.fadeIn(withDuration: 0)
    let wait = SKAction.wait(forDuration: shouldWait ? 4.5 : 0.1)
    
    let animateSequence = shouldWait ? SKAction.sequence([wait, fadeIn, animateAction]) : SKAction.sequence([wait, animateAction])
    let moveSequence = SKAction.sequence([wait, moveAction])

    // adding
    self.addChild(birdNode)
    
    // node
    birdNode.name = "Bird"
    birdNode.xScale = Theme.Scene.Egg.scale
    birdNode.yScale = Theme.Scene.Egg.scale
    birdNode.zPosition = CGFloat(index + 1)
    birdNode.position = CGPoint(x: -1 * UIScreen.main.bounds.width / 2, y: position.y)
    birdNode.alpha = shouldWait ? 0.0 : 1.0
    
    birdNode.run(animateSequence)
    birdNode.run(moveSequence) {
      birdNode.removeAllActions()
      birdNode.run(SKAction.setTexture(birdNormalTexture, resize: true))
    }
    
  }
  
  // MARK: - Helpers
  func getFirstBirdIndex() -> Int {
    children
     .filter({
       $0.name == "Bird"
     })
     .count
  }
  
  func getBirdPosition(index: Int) -> CGPoint {
    switch index {
    case 0: return CGPoint(x: position.x + 150, y: position.y)
    case 1: return CGPoint(x: position.x - 150, y: position.y)
    case 2: return CGPoint(x: position.x + 100, y: position.y)
    case 3: return CGPoint(x: position.x - 100, y: position.y)
    case 4: return CGPoint(x: position.x + 50, y: position.y)
    case 5: return CGPoint(x: position.x - 50, y: position.y)
    case 6: return position
    default: return position
    }
  }
  
  func getBirdImage(index: Int, birds: [Bird], state: BirdState) -> UIImage? {
    guard let bird = birds.first(where: { $0.clade.index == index }) else { return nil }
    return UIImage(named: bird.clade.stringForImage + "_" + bird.style.stringForImage + "_" + state.stringForImage)
  }
}
