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
      node.xScale = Theme.MainTaskListScene.Scene.scale * 1.25
      node.yScale = Theme.MainTaskListScene.Scene.scale * 1.5
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
//      case .ChangeEggClyde(let egg):
//        self.updateEggNode(egg: egg, cracks: egg.cracks, withAnimation: true) { node in
//
//        }
//
//      case .BrokeTheEggWithoutBird(let egg):
//        self.removeEggNode(egg: egg)
//
//      case .BrokeTheEggAndBornTheBirdAndSendTheBirdWalkToTheRight(let egg):
//        switch egg.cracks {
//        case .NoCrack:
//          self.updateEggNode(egg: egg, cracks: .OneCrack, withAnimation: true) { node in
//            self.updateEggNode(egg: egg, cracks: .ThreeCracks, withAnimation: true) { node in
////              self.setupBirdNode(egg: egg) { node in
////                self.animateBirdNode(node: node) { node in
////                  node.removeFromParent()
////                }
////              }
//            }
//          }
//
//        case .OneCrack:
//          self.updateEggNode(egg: egg, cracks: .ThreeCracks, withAnimation: true) { node in
//            self.setupBirdNode(egg: egg) { node in
//              self.animateBirdNode(node: node) { node in
//                node.removeFromParent()
//              }
//            }
//          }
//
//        case .ThreeCracks:
//          self.setupBirdNode(egg: egg) { node in
//            self.animateBirdNode(node: node) { node in
//              node.removeFromParent()
//            }
//          }
//        }
      
      default:
        return
      }
    }
  }
  
  // addEggNode
  func addEggNode(withAnimation: Bool) {
    getFisrtEmptyEggIndex { index in
      self.getEggPositionWithIndex(position: self.position, eggIndex: index) { position in
        guard let image = getEggImageForIndex(index: index) else { return }
        let texture = SKTexture(image: image)
        let node = SKSpriteNode(texture: texture)
        
        // adding
        self.addChild(node)
        
        // node
        node.name = "Egg"
        node.userData = [
          "uid": UUID().uuidString,
          "index": index]
        node.xScale = Theme.MainTaskListScene.Egg.scale
        node.yScale = Theme.MainTaskListScene.Egg.scale
        node.zPosition = CGFloat(index + 2)
        node.alpha = withAnimation ? 0.0 : 1.0
        node.position = position
        if withAnimation {
          node.run(self.fadeInAction)
        }
        
      }
    }
  }
  
  // removeEggNode
  func removeLastEggNode() {
    if let node = children
      .filter({ $0.name == "Egg" })
      .max(by: { ($0.userData?["index"] as? Int ?? 0) < ($1.userData?["index"] as? Int ?? 0) }) {
      node.run(fadeOutAction) {
        node.removeFromParent()
      }
    }
  }
  
  // hatchTheBird
  func hatchTheBird(typeUID: String) {
    
    
  }


//  func bornTheBird(egg: Egg, completion: @escaping (SKNode) -> Void) {
//    if let image = UIImage(named: "курица_обычный_статика"),
//       let node = children.first(where: { $0.userData?["uid"] as? String ?? "" == egg.UID }) {
//
//      let texture = SKTexture(image: image)
//      let action = SKAction.setTexture(texture, resize: true)
//      let wait = SKAction.wait(forDuration: 0.5)
//      let sequence = SKAction.sequence([wait, action])
//      node.run(sequence) {
//        completion(node)
//      }
//    }
//  }
//
//  func sendTheBirdWalkToTheRight(egg: Egg, completion: @escaping (SKNode) -> Void) {
//    if let leftImage = UIImage(named: "курица_обычный_левая_вперед"),
//       let rightImage = UIImage(named: "курица_обычный_правая_вперед"),
//       let node = children.first(where: { $0.userData?["uid"] as? String ?? "" == egg.UID }) {
//
//      let leftTexture = SKTexture(image: leftImage)
//      let rightTexture = SKTexture(image: rightImage)
//     // let action = SKAction.setTexture(leftTexture, resize: true)
//      let animate = SKAction.repeatForever(SKAction.animate(with: [leftTexture, rightTexture], timePerFrame: 0.3))
//      let moveAction = SKAction.move(to: CGPoint(x: UIScreen.main.bounds.width + 50, y: node.position.y), duration: 4.0)
//      let wait = SKAction.wait(forDuration: 0.5)
//      let sequence = SKAction.sequence([wait, moveAction])
//      node.run(animate)
//      node.run(sequence) {
//        completion(node)
//      }
//    }
//  }
//
//  func changeEggClyde(egg: Egg) {
//
//    // проверяем есть ли для данной задачи яйца с другой расой
//    getEggNodesWithSameTask(egg: egg) { oldEggNodes in
//      // удаляем другие яйца
//      removeEggs(eggs: oldEggNodes) {
//        // добавляем наше яйцо
//        self.addEggNode(egg: egg, withAlpha: 0.0) { eggNode in
//          eggNode.run(self.fadeInAction)
//        }
//      }
//    }
//  }
//
//  func addEggNode(egg: Egg, withAlpha alpha: Double, completion: (SKNode) -> Void) {
//
//    // get egg Index
//    getEggIndex(egg: egg) { index in
//      if let image = egg.image {
//
//        // properties
//        let texture = SKTexture(image: image)
//        let eggNode = SKSpriteNode(texture: texture)
//
//        // eggNode
//        eggNode.name = "Egg"
//        eggNode.userData = ["uid": egg.UID, "index": index, "clade": egg.clade.rawValue]
//        eggNode.xScale = Theme.MainTaskListScene.Egg.scale
//        eggNode.yScale = Theme.MainTaskListScene.Egg.scale
//        eggNode.zPosition = CGFloat(index)
//
//        // position
//        getEggPosition(background: self.position, eggIndex: index) { position in
//          eggNode.position = position
//          eggNode.alpha = alpha
//          //  withAnimation ? eggNode.run(fadeInAction) : nil
//          // adding
//          addChild(eggNode)
//          completion(eggNode)
//        }
//      }
//    }
//  }
  
  
  // MARK: - Helpers
  func getFisrtEmptyEggIndex(completion: (Int) -> Void ) {
    let indexes = children
      .filter({
        $0.name == "Egg"
      })
      .compactMap{
        $0.userData?["index"] as? Int
      }
      .sorted()
    
    for (index, busyIndex) in indexes.enumerated() {
      if index != busyIndex {
        completion(index)
        return
      }
    }
    
    completion(indexes.count)
  }
  
  func getEggPositionWithIndex(position: CGPoint, eggIndex index: Int, completion: (CGPoint) -> Void) {
    switch index {
    case 0: completion(CGPoint(x: position.x - 30, y: position.y + 20))
    case 1: completion(CGPoint(x: position.x + 20, y: position.y + 20))
    case 2: completion(CGPoint(x: position.x + 70, y: position.y - 5))
    case 3: completion(CGPoint(x: position.x + 35, y: position.y - 35))
    case 4: completion(CGPoint(x: position.x - 5, y: position.y - 40))
    case 5: completion(CGPoint(x: position.x - 45, y: position.y - 35))
    case 6: completion(CGPoint(x: position.x - 80, y: position.y - 5))
    default: return
    }
  }
  
  func getEggImageForIndex(index: Int) -> UIImage? {
    switch index {
    case 0: return UIImage(named: "яйцо_курица_без_трещин")
    case 1: return UIImage(named: "яйцо_страус_без_трещин")
    case 2: return UIImage(named: "яйцо_пингвин_без_трещин")
    case 3: return UIImage(named: "яйцо_сова_без_трещин")
    case 4: return UIImage(named: "яйцо_попугай_без_трещин")
    case 5: return UIImage(named: "яйцо_орел_без_трещин")
    case 6: return UIImage(named: "яйцо_дракон_без_трещин")
    default: return nil
    }
  }
}
