//
//  SKBirdNode.swift
//  Todooshka
//
//  Created by Pavel Petakov on 03.08.2022.
//

import SpriteKit
import SwiftUI

class SKBirdNode: SKSpriteNode {
  // MARK: - Public
  var action: BirdActionType = .create
  let level: Int

  var wingsIsUp = false
  var randomStaffIsDoing = false

  // MARK: - Private
  // Actions
  private let fadeInWithAnimationAction = SKAction.fadeIn(withDuration: 0.5)
  private let fadeInWithoutAnimationAction = SKAction.fadeIn(withDuration: 0)
  private let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
  private let waitAction = SKAction.wait(forDuration: 0.5)

  private var legsRunningAction: SKAction {
    SKAction.repeatForever(
      SKAction.animate(
        with: [self.rightLegForwardTexture, self.leftLegForwardTexture],
        timePerFrame: 0.3,
        resize: true,
        restore: false))
  }
  private var runFromNestAction: SKAction {
    SKAction.move(
      to: CGPoint(x: UIScreen.main.bounds.width + 50, y: position.y),
      duration: 4.0)
  }

  // Other
  private let clade: Clade

  private var style: BirdStyle

  // func
  func setFrontTextureAction() -> SKAction {
    SKAction.setTexture(
      SKTexture(image: UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.normal.rawValue) ?? UIImage()),
      resize: true
    )
  }

  func setClosedEyesTextureAction() -> SKAction {
    SKAction.setTexture(
      SKTexture(image: UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.closedEyes.rawValue) ?? UIImage()),
      resize: true
    )
  }

  func setRaiseWingsTextureAction() -> SKAction {
    SKAction.setTexture(
      SKTexture(image: UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.raisedWings.rawValue) ?? UIImage()),
      resize: true
    )
  }

  //  private var frontImage: UIImage { UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.Normal.rawValue) ?? UIImage() }
  private var rightLegForwardImage: UIImage {
    UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.rightLegForward.rawValue) ?? UIImage()
  }
  private var leftLegForwardImage: UIImage {
    UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.leftLegForward.rawValue) ?? UIImage()
  }

  // Texture
  private var rightLegForwardTexture: SKTexture { SKTexture(image: rightLegForwardImage) }
  private var leftLegForwardTexture: SKTexture { SKTexture(image: leftLegForwardImage) }

  // MARK: - Init
  init(level: Int, style: BirdStyle) {
    // Super Init
    self.level = level
    self.clade = Clade(level: level)
    self.style = style
    super.init(texture: nil, color: .clear, size: .zero)
    // Setup
    name = "Bird"
    xScale = Style.Scene.Egg.scale
    yScale = Style.Scene.Egg.scale
    zPosition = CGFloat(clade.level + 1)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions
  func changeStyle(style: BirdStyle, withDelay: Bool) {
    switch (action, withDelay) {
    case (.create, _):
      self.style = style
      run(SKAction.sequence([setFrontTextureAction(), fadeInWithoutAnimationAction]))

    case (.hide, true):
      self.style = style
      run(SKAction.sequence([waitAction, setFrontTextureAction(), fadeInWithAnimationAction]))

    case (.hide, false):
      self.style = style
      run(SKAction.sequence([setFrontTextureAction(), fadeInWithAnimationAction]))

    case (.sitting, _):
      run(fadeOutAction) {
        self.style = style
        self.run(SKAction.sequence([self.setFrontTextureAction(), self.fadeInWithAnimationAction]))
      }
    }

    if randomStaffIsDoing == false {
      self.randomStaffIsDoing = true
      self.doRandomStaff()
    }
  }

  func runFromNest(completion: @escaping (() -> Void)) {
    run(SKAction.sequence([waitAction, legsRunningAction]))
    run(SKAction.sequence([waitAction, runFromNestAction])) {
      self.removeFromParent()
      completion()
    }
  }

  func upWings() {
    run(setRaiseWingsTextureAction())
  }

  func dowsWings() {
    run(setFrontTextureAction())
  }

  func hide() {
    run(fadeOutAction) {
      self.removeAllActions()
      self.randomStaffIsDoing = false
    }
  }

  func doRandomStaff() {
    let waitBefore = SKAction.wait(forDuration: 10, withRange: 10)

    let randomAction = SKAction.run({
      self.run(Int.random(in: 0...1) == 0 ? self.clapWithEyes() : self.flapWithWings())
    })

    let sequence = SKAction.sequence([waitBefore, randomAction])
    self.run(SKAction.repeatForever(sequence))
  }

  func clapWithEyes() -> SKAction {
    SKAction.sequence([setClosedEyesTextureAction(), waitAction, setFrontTextureAction()])
  }

  func flapWithWings() -> SKAction {
    SKAction.sequence([setRaiseWingsTextureAction(), waitAction, setFrontTextureAction()])
  }
}
