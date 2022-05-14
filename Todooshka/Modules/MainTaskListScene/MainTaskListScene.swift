//
//  MainTaskListScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.11.2021.
//

import UIKit
import SpriteKit

enum ActionType {
  case Create
  case Update
}

class MainTaskListScene: SKScene {
  
  // MARK: - Properties
 // private var backgroundNode: SKSpriteNode!
  private var eggs: [Egg] = []
  
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
      node.xScale = Theme.MainTaskListScene.Scene.scale
      node.yScale = Theme.MainTaskListScene.Scene.scale
      node.name = "background"
      addChild(node)
    }
  }
  
  // MARK: - Actions
  func runActions(actions: [MainTaskListSceneAction]) {
    actions.forEach { action in
      switch action.action {
      case .CreateTheEgg(let egg, let withAnimation):
        self.setupEggNode(egg: egg, cracks: egg.cracks, withAnimation: withAnimation)
      case .ChangeEggClyde(let egg):
        self.setupEggNode(egg: egg, cracks: egg.cracks, withAnimation: true)
      case .BrokeTheEggWithoutBird(let egg):
        self.removeEggNode(egg: egg)
      case .BrokeTheEggAndBornTheBirdAndSendTheBirdWalkToTheRight(let egg):
        switch egg.cracks {
        case .NoCrack:
          self.setupEggNode(egg: egg, cracks: .OneCrack, withAnimation: true) { _ in
            self.setupEggNode(egg: egg, cracks: .ThreeCracks, withAnimation: true) { _ in
              self.setupBirdNode(egg: egg) { node in
                self.animateBirdNode(node: node) { node in
                  node.removeFromParent()
                }
              }
            }
          }
        case .OneCrack:
          self.setupEggNode(egg: egg, cracks: .ThreeCracks, withAnimation: true) { _ in
            self.setupBirdNode(egg: egg) { node in
              self.animateBirdNode(node: node) { node in
                node.removeFromParent()
              }
            }
          }
        case .ThreeCracks:
          self.setupBirdNode(egg: egg) { node in
            self.animateBirdNode(node: node) { node in
              node.removeFromParent()
            }
          }
        }
      default:
        return
      }
    }
  }
  
  // setupEggNode
  func setupEggNode(egg: Egg, cracks: CrackType, withAnimation: Bool) {
    self.setupEggNode(egg: egg, cracks: cracks, withAnimation: withAnimation) { _ in
      return
    }
  }
  
  func setupEggNode(egg: Egg, cracks: CrackType, withAnimation: Bool, completion: (SKNode) -> Void) {
    
    guard let image = egg.getImageForCracks(cracks: cracks) else { return }
    
    if let node = children.first(where: { $0.name == "Egg" && $0.userData?["uid"] as? String == egg.UID }) {
      
    } else {
      let node 
    }
    
    
    if let image = egg.getImageForState(state: state),
       let node = children.first(where: { $0.userData?["uid"] as? String ?? "" == egg.UID }) {
      
      let texture = SKTexture(image: image)
      let action = SKAction.setTexture(texture, resize: false)
      let wait = SKAction.wait(forDuration: 0.5)
      let sequence = SKAction.sequence([wait, action])
      node.run(sequence) {
        completion(node)
      }
    }
  }
  
  // removeEggNode
  func removeEggNode(egg: Egg) {
    if let node = children.first(where: { $0.name == "Egg" && $0.userData?["uid"] as? String == egg.UID }) {
      let action = SKAction.fadeOut(withDuration: 1.0)
      node.run(action) {
        node.removeFromParent()
      }
    }
  }
  
  // setupBirdNode
  func setupBirdNode(egg: Egg, completion: @escaping (SKNode) -> Void) {
    
  }
  
  func animateBirdNode(node: SKNode, completion: @escaping (SKNode) -> Void) {
    
  }
  
  
  func createTheEgg(egg: Egg, withAnimation: Bool) {
    addEggNode(egg: egg, withAlpha: withAnimation ? 0.0 : 1.0) { eggNode in
      if withAnimation { eggNode.run(self.fadeInAction) }
    }
  }
  
  func bornTheBird(egg: Egg, completion: @escaping (SKNode) -> Void) {
    if let image = UIImage(named: "курица_обычный_статика"),
       let node = children.first(where: { $0.userData?["uid"] as? String ?? "" == egg.UID }) {
      
      let texture = SKTexture(image: image)
      let action = SKAction.setTexture(texture, resize: true)
      let wait = SKAction.wait(forDuration: 0.5)
      let sequence = SKAction.sequence([wait, action])
      node.run(sequence) {
        completion(node)
      }
    }
  }
  
  func sendTheBirdWalkToTheRight(egg: Egg, completion: @escaping (SKNode) -> Void) {
    if let leftImage = UIImage(named: "курица_обычный_левая_вперед"),
       let rightImage = UIImage(named: "курица_обычный_правая_вперед"),
       let node = children.first(where: { $0.userData?["uid"] as? String ?? "" == egg.UID }) {
      
      let leftTexture = SKTexture(image: leftImage)
      let rightTexture = SKTexture(image: rightImage)
     // let action = SKAction.setTexture(leftTexture, resize: true)
      let animate = SKAction.repeatForever(SKAction.animate(with: [leftTexture, rightTexture], timePerFrame: 0.3))
      let moveAction = SKAction.move(to: CGPoint(x: UIScreen.main.bounds.width + 50, y: node.position.y), duration: 4.0)
      let wait = SKAction.wait(forDuration: 0.5)
      let sequence = SKAction.sequence([wait, moveAction])
      node.run(animate)
      node.run(sequence) {
        completion(node)
      }
    }
  }
  
  func changeEggClyde(egg: Egg) {
    
    // проверяем есть ли для данной задачи яйца с другой расой
    getEggNodesWithSameTask(egg: egg) { oldEggNodes in
      // удаляем другие яйца
      removeEggs(eggs: oldEggNodes) {
        // добавляем наше яйцо
        self.addEggNode(egg: egg, withAlpha: 0.0) { eggNode in
          eggNode.run(self.fadeInAction)
        }
      }
    }
  }
  
  func addEggNode(egg: Egg, withAlpha alpha: Double, completion: (SKNode) -> Void) {
    
    // get egg Index
    getEggIndex(egg: egg) { index in
      if let image = egg.image {
        
        // properties
        let texture = SKTexture(image: image)
        let eggNode = SKSpriteNode(texture: texture)
        
        // eggNode
        eggNode.name = "Egg"
        eggNode.userData = ["uid": egg.UID, "index": index, "clade": egg.clade.rawValue]
        eggNode.xScale = Theme.MainTaskListScene.Egg.scale
        eggNode.yScale = Theme.MainTaskListScene.Egg.scale
        eggNode.zPosition = CGFloat(index)
        
        // position
        getEggPosition(background: self.position, eggIndex: index) { position in
          eggNode.position = position
          eggNode.alpha = alpha
          //  withAnimation ? eggNode.run(fadeInAction) : nil
          // adding
          addChild(eggNode)
          completion(eggNode)
        }
      }
    }
  }
  
  func removeEggs(eggs: [SKNode], completion: @escaping () -> Void) {
    eggs.forEach { node in
      node.run(fadeOutAction) {
        node.removeFromParent()
        completion()
      }
    }
  }
  
  func removeTheEgg(egg: Egg) {
    if let node = children.first(where: { $0.userData?["uid"] as? String ?? "" == egg.UID }) {
      let action = SKAction.fadeOut(withDuration: 1.0)
      node.run(action) {
        node.removeFromParent()
      }
    }
  }

  
  // MARK: - Helpers
  func getEggNodesWithSameTask(egg: Egg, completion: ([SKNode]) -> Void) {
    completion(children.filter{
      $0.userData?["uid"] as? String ?? "" == egg.UID
    })
  }
  
  func getEggIndex(egg: Egg, completion: (Int) -> Void ) {
    let eggNodes = children.filter({ $0.name == "Egg" })
    if eggNodes.first(where: { ($0.userData?["index"] as? Int ?? -1 == 0)
      && ( $0.userData?["uid"] as? String ?? "" != egg.UID ) }) == nil { completion(0) }
    else if eggNodes.first(where: { ($0.userData?["index"] as? Int ?? -1 == 1)
      && ( $0.userData?["uid"] as? String ?? "" != egg.UID ) }) == nil { completion(1) }
    else if eggNodes.first(where: { ($0.userData?["index"] as? Int ?? -1 == 2 )
      && ( $0.userData?["uid"] as? String ?? "" != egg.UID ) }) == nil { completion(2) }
    else if eggNodes.first(where: { ($0.userData?["index"] as? Int ?? -1 == 3)
      && ( $0.userData?["uid"] as? String ?? "" != egg.UID ) }) == nil { completion(3) }
    else if eggNodes.first(where: { ($0.userData?["index"] as? Int ?? -1 == 4)
      && ( $0.userData?["uid"] as? String ?? "" != egg.UID ) }) == nil { completion(4) }
    else if eggNodes.first(where: { ($0.userData?["index"] as? Int ?? -1 == 5)
      && ( $0.userData?["uid"] as? String ?? "" != egg.UID ) }) == nil { completion(5) }
    return
  }
  
  func getEggPosition(background position: CGPoint, eggIndex index: Int, completion: (CGPoint) -> Void) {
    switch index {
    //case 0: completion(CGPoint(x: position.x - 35, y: position.y + 15))
    case 0: completion(CGPoint(x: position.x - 35, y: position.y - 15))
    case 1: completion(CGPoint(x: position.x - 80, y: position.y + 5))
    case 2: completion(CGPoint(x: position.x + 10, y: position.y + 5))
    case 3: completion(CGPoint(x: position.x - 57, y: position.y - 5))
    case 4: completion(CGPoint(x: position.x - 13, y: position.y - 5))
    case 5: completion(CGPoint(x: position.x - 35, y: position.y - 10))
    default: return
    }
  }
}
