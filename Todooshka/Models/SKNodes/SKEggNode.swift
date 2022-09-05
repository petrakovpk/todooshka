//
//  SKEggNode.swift
//  Todooshka
//
//  Created by Pavel Petakov on 03.08.2022.
//

import SpriteKit

class SKEggNode: SKSpriteNode {
  
  // MARK: - Public
  var action: EggActionType = .Init
  var isCracking: Bool = false
  var nestPosition: CGPoint {
    CGPoint(
      x: (Data.Egg.deltaFromNest[index]?.x ?? 0) + parentPosition.x,
      y: (Data.Egg.deltaFromNest[index]?.y ?? 0) + parentPosition.y
    )
  }
  
  // MARK: - Private
  // Actions
  private let fadeInWithoutDuration = SKAction.fadeIn(withDuration: 0.0)
  private let fadeInWithDuration = SKAction.fadeIn(withDuration: 1.0)
  private let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
  private var setNoCracksTexture: SKAction { SKAction.setTexture(noCracksTexture, resize: false) }
  private var setOneCrackTexture: SKAction { SKAction.setTexture(oneCrackTexture, resize: false) }
  private var setThreeCracksTexture: SKAction { SKAction.setTexture(threeCracksTexture, resize: true) }
  private let wait = SKAction.wait(forDuration: 0.5)
  
  // Other
  private let index: Int
  private let parentPosition: CGPoint
  
  // Image
  private var noCracksImage: UIImage { UIImage(named: "яйцо_" + Clade.init(index: index).rawValue + "_" + CrackType.NoCrack.stringForImage) ?? UIImage() }
  private var oneCrackImage: UIImage { UIImage(named: "яйцо_" + Clade.init(index: index).rawValue + "_" + CrackType.OneCrack.stringForImage) ?? UIImage() }
  private var threeCracksImage: UIImage { UIImage(named: "яйцо_" + Clade.init(index: index).rawValue + "_" + CrackType.ThreeCracks.stringForImage) ?? UIImage() }
  
  // Texture
  private var noCracksTexture: SKTexture { SKTexture(image: noCracksImage) }
  private var oneCrackTexture: SKTexture { SKTexture(image: oneCrackImage) }
  private var threeCracksTexture: SKTexture { SKTexture(image: threeCracksImage) }
  
  // MARK: - Init
  init(index: Int, parentPosition: CGPoint) {
    // Super init
    self.index = index
    self.parentPosition = parentPosition
    super.init(texture: nil, color: .clear, size: .zero)
    
    // Other
    name = "Egg"
    size = noCracksTexture.size()
    texture = noCracksTexture
    zPosition = CGFloat(index + 1)
    xScale = Theme.Scene.Egg.scale
    yScale = Theme.Scene.Egg.scale
    alpha = 0.0
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Actions
  func show(state: EggActionType, withAnimation: Bool, completion: (() -> Void)?) {
    switch (state, withAnimation) {
    case (.NoCracks, true):
      run(SKAction.sequence([setNoCracksTexture, fadeInWithDuration]))
    case (.NoCracks, false):
      run(SKAction.sequence([setNoCracksTexture, fadeInWithoutDuration]))
    case (.Crack(_), _):
      run(setThreeCracksTexture) { self.alpha = 0.7 }
    default:
      return
    }
  }
  
  func crack(completion: (() -> Void)?) {
    isCracking = true
    run(SKAction.sequence([setOneCrackTexture, wait, setThreeCracksTexture, wait])) {
      self.alpha = 0.7
      self.isCracking = false
      completion?()
    }
  }
  
  func forceCrack() {
    run(setThreeCracksTexture) { self.alpha = 0.7 }
  }
  
  func repair() {
    run(setNoCracksTexture) { self.alpha = 1.0 }
  }
  
  func hide() {
    run(fadeOutAction)
  }
}
