//
//  SKEggNode.swift
//  Todooshka
//
//  Created by Pavel Petakov on 03.08.2022.
//

import SpriteKit

class SKEggNode: SKSpriteNode {
  
  // MARK: - Actions
  private let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
  private let fadeInAction = SKAction.fadeIn(withDuration: 1.0)
  
  // MARK: - Properties
  private let data: [Int: CGPoint] = [
    1: CGPoint(x: -30, y: 20),
    2: CGPoint(x: 20, y: 20),
    3: CGPoint(x: 70, y: -5),
    4: CGPoint(x: 35, y: -35),
    5: CGPoint(x: -5, y: -40),
    6: CGPoint(x: -45, y: -35),
    7: CGPoint(x: -80, y: -5)
  ]
  
  private let eggN: Int
  //private var cracks: CrackType = .NoCrack
  
  private var image: UIImage? {
    guard let clade = Clade.init(eggN: eggN) else { return nil }
    return UIImage(named: "яйцо_" + clade.rawValue + "_" + CrackType.NoCrack.stringForImage)
  }
  
  public var deltaPosition: CGPoint {
    data[eggN] ?? CGPoint(x: 0, y: 0)
  }

  // MARK: - Init
  init(eggN: Int) {
    self.eggN = eggN
    super.init(texture: nil, color: .clear, size: .zero)
    
    guard let image = image else { return }
    
    name = "Egg"
    size = SKTexture(image: image).size()
    texture = SKTexture(image: image)
    zPosition = CGFloat(eggN + 1)
    xScale = Theme.Scene.Egg.scale
    yScale = Theme.Scene.Egg.scale
    alpha = 0.0
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Actions
  func show(withAnimation: Bool, completion: (() -> Void)?) {
    withAnimation ? run(fadeInAction) : (alpha = 1.0)
  }
  
  func crack(completion: (() -> Void)?) {
    
    guard let clade = Clade.init(eggN: eggN),
          let oneCrackImage = UIImage(named: "яйцо_" + clade.rawValue + "_" + CrackType.OneCrack.stringForImage),
          let threeCracksImage = UIImage(named: "яйцо_" + clade.rawValue + "_" + CrackType.ThreeCracks.stringForImage) else { return }
     
    let oneCrackTexture = SKTexture(image: oneCrackImage)
    let threeCracksTexture = SKTexture(image: threeCracksImage)
    
    let wait = SKAction.wait(forDuration: 0.5)
    let doOneCrack = SKAction.setTexture(oneCrackTexture, resize: false)
    let doThreeCracks = SKAction.setTexture(threeCracksTexture, resize: true)
    let sequence = SKAction.sequence([doOneCrack, wait, doThreeCracks, wait])
    
    run(sequence) {
      self.alpha = 0.7
      completion?()
    }
  }
  
  func hide(completion: (() -> Void)?) {
    run(fadeOutAction)
  }
  
}
