//
//  MainTaskListScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.11.2021.
//

import UIKit
import SpriteKit

class MainTaskListScene: SKScene {
  
  // MARK: - Properties
  private let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
  private let fadeInAction = SKAction.fadeIn(withDuration: 1.0)
  
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
      case .CreateTheEgg(let withAnimation):
        addEggNode(withAnimation: withAnimation)
      case .RemoveTheEgg:
        removeLastEggNode()
      case .HatchTheBird(birds: let birds):
        hatchTheBird(birds: birds)
      default:
        return
      }
    }
  }
  
  // addEggNode
  func addEggNode(withAnimation: Bool) {
    
    let index = getFirstEmptyEggIndex()
    
    guard let position = getEggPositionWithIndex(position: self.position, eggIndex: index) else { return }
    guard let image = getEggImage(index: index, type: .NoCrack) else { return }
    
    let texture = SKTexture(image: image)
    let node = SKSpriteNode(texture: texture)
    
    // adding
    self.addChild(node)
    
    // node
    node.name = "Egg"
    node.userData = [
      "uid": UUID().uuidString,
      "isBroken": false,
      "index": index]
    node.xScale = Theme.Scene.Egg.scale
    node.yScale = Theme.Scene.Egg.scale
    node.zPosition = CGFloat(index + 2)
    node.alpha = withAnimation ? 0.0 : 1.0
    node.position = position
    if withAnimation {
      node.run(self.fadeInAction)
    }
  }
  
  // removeEggNode
  func removeLastEggNode() {
    // last egg
    if let node = children
      .filter({ $0.name == "Egg" })
      .max(by: {
        $0.userData?["index"] as? Int ?? 0 < $1.userData?["index"] as? Int ?? 0
      }) {
      node.run(fadeOutAction) {
        node.removeFromParent()
      }
    }
  }
  
  // hatchTheBird
  func hatchTheBird(birds: [Bird]) {
    
    guard let node = children.filter({
      $0.name == "Egg" &&
      $0.userData?["isBroken"] as? Bool ?? false == false
    }).min(by: {
      $0.userData?["index"] as? Int ?? 0 < $1.userData?["index"] as? Int ?? 0
    }) else { return }
    
    guard let index = node.userData?["index"] as? Int else { return }
    guard let oneCrackImage = getEggImage(index: index, type: .OneCrack) else { return }
    guard let threeCracksImage = getEggImage(index: index, type: .ThreeCracks) else { return }
    
    let oneCrackTexture = SKTexture(image: oneCrackImage)
    let threeCrackTexture = SKTexture(image: threeCracksImage)
    
    let wait = SKAction.wait(forDuration: 0.5)
    
    let oneCrackAction = SKAction.setTexture(oneCrackTexture, resize: true)
    let threeCrackAction = SKAction.setTexture(threeCrackTexture, resize: true)
    
    let sequence = SKAction.sequence([wait, oneCrackAction, wait, threeCrackAction, wait])
    
    node.userData?.setValue(true, forKey: "isBroken")
    
    node.run(sequence) {
      node.alpha = 0.7
      
      guard let birdNormalImage = self.getBirdImage(index: index, birds: birds, state: .Normal) else { return }
      guard let birdLeftLegForwardImage = self.getBirdImage(index: index, birds: birds, state: .LeftLegForward) else { return }
      guard let birdRightLegForwardImage = self.getBirdImage(index: index, birds: birds, state: .RightLegForward) else { return }
      
      let birdNormalTexture = SKTexture(image: birdNormalImage)
      let birdLeftLegForwardTexture = SKTexture(image: birdLeftLegForwardImage)
      let birdRightLegForwardTexture = SKTexture(image: birdRightLegForwardImage)

      let birdNode = SKSpriteNode(texture: birdNormalTexture)

      let animateAction = SKAction.repeatForever(SKAction.animate(with: [birdLeftLegForwardTexture, birdRightLegForwardTexture], timePerFrame: 0.3, resize: true, restore: false))
      let moveAction = SKAction.move(to: CGPoint(x: UIScreen.main.bounds.width + 50, y: birdNode.position.y), duration: 4.0)
      
      let animateSequence = SKAction.sequence([wait, animateAction])
      let moveSequence = SKAction.sequence([wait, moveAction])
      
      // adding
      self.addChild(birdNode)
      
      // node
      birdNode.name = "Bird"
      birdNode.xScale = Theme.Scene.Egg.scale
      birdNode.yScale = Theme.Scene.Egg.scale
      birdNode.zPosition = node.zPosition + 1
      birdNode.position = node.position
      
      birdNode.run(animateSequence)
      birdNode.run(moveSequence) {
        birdNode.removeFromParent()
      }
    }
  }
  
  // MARK: - Helpers
  func getFirstEmptyEggIndex() -> Int {
    children
     .filter({
       $0.name == "Egg"
     })
     .count
  }
  
  func getEggPositionWithIndex(position: CGPoint, eggIndex index: Int) -> CGPoint? {
    switch index {
    case 0: return CGPoint(x: position.x - 30, y: position.y + 20)
    case 1: return CGPoint(x: position.x + 20, y: position.y + 20)
    case 2: return CGPoint(x: position.x + 70, y: position.y - 5)
    case 3: return CGPoint(x: position.x + 35, y: position.y - 35)
    case 4: return CGPoint(x: position.x - 5, y: position.y - 40)
    case 5: return CGPoint(x: position.x - 45, y: position.y - 35)
    case 6: return CGPoint(x: position.x - 80, y: position.y - 5)
    default :return nil
    }
  }
  
  func getEggImage(index: Int, type: CrackType) -> UIImage? {
    guard let clade = BirdClade.init(index: index) else { return nil }
    return UIImage(named: "яйцо_" + clade.stringForImage + "_" + type.stringForImage)
  }
  
  func getBirdImage(index: Int, birds: [Bird], state: BirdState) -> UIImage? {
    guard let bird = birds.first(where: { $0.clade.index == index }) else { return nil }
    return UIImage(named: bird.clade.stringForImage + "_" + bird.style.stringForImage + "_" + state.stringForImage)
  }
  
}
