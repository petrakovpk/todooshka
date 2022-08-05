//
//  NestScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.11.2021.
//

import UIKit
import SpriteKit

enum EggSceneStatus {
  case Hide, Cracked, Shown
}

class NestScene: SKScene {
  
  // MARK: - Data
  public var birds: [Bird] = []
  
  private var data: [Int: EggSceneStatus] = [1: .Hide, 2: .Hide, 3: .Hide, 4: .Hide, 5: .Hide, 6: .Hide, 7: .Hide]
  
  // MARK: - UI Nodes
  private let background: SKSpriteNode = {
    let node = SKSpriteNode()
    node.xScale = Theme.Scene.scale * 1.5
    node.yScale = Theme.Scene.scale * 1.5
    node.name = "background"
    return node
  }()
  
  private let eggN1 = SKEggNode(eggN: 1)
  private let eggN2 = SKEggNode(eggN: 2)
  private let eggN3 = SKEggNode(eggN: 3)
  private let eggN4 = SKEggNode(eggN: 4)
  private let eggN5 = SKEggNode(eggN: 5)
  private let eggN6 = SKEggNode(eggN: 6)
  private let eggN7 = SKEggNode(eggN: 7)
  
  // MARK: - Lifecycle
  override func didMove(to view: SKView) {
    if let scene = scene {
      
      // scene
      scene.size = view.size
      scene.backgroundColor = .clear
      
      // adding
      addChild(background)
      addChild(eggN1)
      addChild(eggN2)
      addChild(eggN3)
      addChild(eggN4)
      addChild(eggN5)
      addChild(eggN6)
      addChild(eggN7)
      
      // background
      background.position = CGPoint(x: position.x + 40, y: position.y)
      
      // eggs
      eggN1.position = CGPoint(x: position.x + eggN1.deltaPosition.x, y: position.y + eggN1.deltaPosition.y)
      eggN2.position = CGPoint(x: position.x + eggN2.deltaPosition.x, y: position.y + eggN2.deltaPosition.y)
      eggN3.position = CGPoint(x: position.x + eggN3.deltaPosition.x, y: position.y + eggN3.deltaPosition.y)
      eggN4.position = CGPoint(x: position.x + eggN4.deltaPosition.x, y: position.y + eggN4.deltaPosition.y)
      eggN5.position = CGPoint(x: position.x + eggN5.deltaPosition.x, y: position.y + eggN5.deltaPosition.y)
      eggN6.position = CGPoint(x: position.x + eggN6.deltaPosition.x, y: position.y + eggN6.deltaPosition.y)
      eggN7.position = CGPoint(x: position.x + eggN7.deltaPosition.x, y: position.y + eggN7.deltaPosition.y)
    }
  }
  
  // MARK: - Setup
  func setup(with backgroundImage: UIImage) {
    let texture = SKTexture(image: backgroundImage)
    let action = SKAction.setTexture(texture, resize: false)
    background.run(action)
  }
  
  
  // MARK: - Actions
  func run(actions: [NestSceneAction]) {
    actions.forEach { action in
      switch action.action {
      case .AddTheEgg(let withAnimation):
        addTheEgg(withAnimation: withAnimation)
      case .RemoveTheEgg:
        removeTheEgg()
      case .HatchTheBird(let typeUID):
        crackTheEgg { self.hatchTheBird(eggN: $0, typeUID: typeUID) }
      }
    }
  }
  
  // addEggNode
  func addTheEgg(withAnimation: Bool) {
    
    guard let eggN = data.filter({ $0.value == .Hide }).min(by: { $0.key < $1.key })?.key else { return }
    
    switch eggN {
    case 1: eggN1.show(withAnimation: withAnimation, completion: nil); data[1] = .Shown
    case 2: eggN2.show(withAnimation: withAnimation, completion: nil); data[2] = .Shown
    case 3: eggN3.show(withAnimation: withAnimation, completion: nil); data[3] = .Shown
    case 4: eggN4.show(withAnimation: withAnimation, completion: nil); data[4] = .Shown
    case 5: eggN5.show(withAnimation: withAnimation, completion: nil); data[5] = .Shown
    case 6: eggN6.show(withAnimation: withAnimation, completion: nil); data[6] = .Shown
    case 7: eggN7.show(withAnimation: withAnimation, completion: nil); data[7] = .Shown
    default: return
    }
  }
  
  func removeTheEgg() {
    
    guard let eggN = data.filter({ $0.value == .Shown }).max(by: { $0.key < $1.key })?.key else { return }
    
    switch eggN {
    case 1: eggN1.hide(completion: nil); data[1] = .Hide
    case 2: eggN2.hide(completion: nil); data[2] = .Hide
    case 3: eggN3.hide(completion: nil); data[3] = .Hide
    case 4: eggN4.hide(completion: nil); data[4] = .Hide
    case 5: eggN5.hide(completion: nil); data[5] = .Hide
    case 6: eggN6.hide(completion: nil); data[6] = .Hide
    case 7: eggN7.hide(completion: nil); data[7] = .Hide
    default: return
    }
  }
  
  func crackTheEgg(completion: @escaping (Int) -> Void) {
    
    guard let eggN = data.filter({ $0.value == .Shown }).min(by: { $0.key < $1.key })?.key else { return }
    
    switch eggN {
    case 1: eggN1.crack(completion: { completion(eggN) }); data[1] = .Cracked
    case 2: eggN2.crack(completion: { completion(eggN) }); data[2] = .Cracked
    case 3: eggN3.crack(completion: { completion(eggN) }); data[3] = .Cracked
    case 4: eggN4.crack(completion: { completion(eggN) }); data[4] = .Cracked
    case 5: eggN5.crack(completion: { completion(eggN) }); data[5] = .Cracked
    case 6: eggN6.crack(completion: { completion(eggN) }); data[6] = .Cracked
    case 7: eggN7.crack(completion: { completion(eggN) }); data[7] = .Cracked
    default: return
    }
  }
  
  func hatchTheBird(eggN: Int, typeUID: String) {
    
    guard let bird = birds.first(where: { $0.clade.eggN == eggN && $0.typesUID.contains{ $0 == typeUID }}),
          let clade = Clade(eggN: eggN) else { return }
    
    let node = SKBirdNode(clade: clade, style: bird.style)
    
    // adding
    addChild(node)
    
    // node
    node.position = CGPoint(x: position.x + node.hatchingPosition.x, y: position.y + node.hatchingPosition.y)
    node.hatchAndRunToTheRight()
    
  }
  
}
