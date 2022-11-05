//
//  SKEggNode.swift
//  Todooshka
//
//  Created by Pavel Petakov on 03.08.2022.
//

import SpriteKit

class SKEggNode: SKSpriteNode {

  // MARK: - Public
  var action: EggActionType = .create

  // MARK: - Private
  // Actions
  private let fadeInWithoutDuration = SKAction.fadeIn(withDuration: 0.0)
  private let fadeTo07WithoutDuration = SKAction.fadeAlpha(to: 0.7, duration: 0.0)
  private let fadeInWithDuration = SKAction.fadeIn(withDuration: 1.0)
  private let fadeTo07WithDuration = SKAction.fadeAlpha(to: 0.7, duration: 1.0)
  private let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
  private var setNoCracksTexture: SKAction { SKAction.setTexture(noCracksTexture, resize: false) }
  private var setOneCrackTexture: SKAction { SKAction.setTexture(oneCrackTexture, resize: false) }
  private var setThreeCracksTexture: SKAction { SKAction.setTexture(threeCracksTexture, resize: false) }
  private let wait = SKAction.wait(forDuration: 0.5)

  // Other
  let level: Int

  // Image
  private var noCracksImage: UIImage { UIImage(named: "яйцо_" + Clade.init(level: level).rawValue + "_" + CrackType.noCrack.stringForImage) ?? UIImage() }
  private var oneCrackImage: UIImage { UIImage(named: "яйцо_" + Clade.init(level: level).rawValue + "_" + CrackType.oneCrack.stringForImage) ?? UIImage() }
  private var threeCracksImage: UIImage { UIImage(named: "яйцо_" + Clade.init(level: level).rawValue + "_" + CrackType.threeCracks.stringForImage) ?? UIImage() }

  // Texture
  private var noCracksTexture: SKTexture { SKTexture(image: noCracksImage) }
  private var oneCrackTexture: SKTexture { SKTexture(image: oneCrackImage) }
  private var threeCracksTexture: SKTexture { SKTexture(image: threeCracksImage) }

  // MARK: - Init
  init(level: Int) {
    self.level = level
    super.init(texture: nil, color: .clear, size: .zero)

    name = "Egg"
    size = noCracksTexture.size()
    texture = noCracksTexture
    xScale = Style.Scene.Egg.scale
    yScale = Style.Scene.Egg.scale
    alpha = 0.0

    switch level {
    case 1: zPosition = 3
    case 2: zPosition = 4
    case 3: zPosition = 5
    case 4: zPosition = 6
    case 5: zPosition = 7
    case 6: zPosition = 6
    case 7: zPosition = 5
    default: return
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions
  func show(state: EggActionType, withAnimation: Bool, completion: (() -> Void)?) {

    switch (state, withAnimation) {
    case (.noCracks, true):
      run(SKAction.sequence([setNoCracksTexture, fadeInWithDuration]))
      return
    case (.noCracks, false):
      run(SKAction.sequence([setNoCracksTexture, fadeInWithoutDuration]))
      return
    case (.crack, true):
      run(SKAction.sequence([setThreeCracksTexture, fadeTo07WithDuration]))
      return
    case (.crack, false):
      run(SKAction.sequence([setThreeCracksTexture, fadeTo07WithoutDuration]))
      return
    default:
      return
    }
  }

  func crack(completion: (() -> Void)?) {
    run(SKAction.sequence([setOneCrackTexture, wait, setThreeCracksTexture, wait])) {
      self.alpha = 0.7
      completion?()
    }
  }

  func repair() {
    run(setNoCracksTexture) { self.alpha = 1.0 }
  }

  func hide() {
    run(fadeOutAction)
  }
}
