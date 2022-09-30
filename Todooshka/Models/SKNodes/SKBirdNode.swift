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
  var action: BirdActionType = .Init
  let level: Int

  var wingsIsUp: Bool = false
  var randomStaffIsDoing: Bool = false
  
  // MARK: - Private
  // Actions
  private let fadeInWithAnimationAction = SKAction.fadeIn(withDuration: 0.5)
  private let fadeInWithoutAnimationAction = SKAction.fadeIn(withDuration: 0)
  private let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
  private let waitAction = SKAction.wait(forDuration: 0.5)
  
  private var setFrontTextureAction: SKAction { SKAction.setTexture(frontTexture, resize: true) }
  private var setClosedEyesTextureAction: SKAction { SKAction.setTexture(closedEyesTexture, resize: true) }
  private var raiseWingsTextureAction: SKAction { SKAction.setTexture(raisedWingsTexture, resize: true) }
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
  
  private var style: Style {
    didSet {
      run(setFrontTextureAction)
    }
  }
  
  // Image
  private var frontImage: UIImage { UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.Normal.rawValue) ?? UIImage() }
  private var rightLegForwardImage: UIImage { UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.RightLegForward.rawValue) ?? UIImage() }
  private var leftLegForwardImage: UIImage { UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.LeftLegForward.rawValue) ?? UIImage() }
  private var closedEyesImage: UIImage { UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.ClosedEyes.rawValue) ?? UIImage() }
  private var raisedWingsImage: UIImage { UIImage(named: clade.rawValue + "_" + style.imageName + "_" + BirdState.RaisedWings.rawValue) ?? UIImage() }
  
  // Texture
  private var frontTexture: SKTexture { SKTexture(image: frontImage) }
  private var rightLegForwardTexture: SKTexture { SKTexture(image: rightLegForwardImage) }
  private var leftLegForwardTexture: SKTexture { SKTexture(image: leftLegForwardImage) }
  private var closedEyesTexture: SKTexture { SKTexture(image: closedEyesImage) }
  private var raisedWingsTexture: SKTexture {  SKTexture(image: raisedWingsImage) }

  // MARK: - Init
  init(level: Int, style: Style) {
    // Super Init
    self.level = level
    self.clade = Clade(level: level)
    self.style = style
   // self.scenePosition = scenePosition
    super.init(texture: nil, color: .clear, size: .zero)
    // Setup
    name = "Bird"
    xScale = Theme.Scene.Egg.scale
    yScale = Theme.Scene.Egg.scale
    zPosition = CGFloat(clade.level + 1)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Actions
  func changeStyle(style: Style, withDelay: Bool) {
    switch (action, withDelay) {
    
    case (.Init, _):
      self.style = style
      run(fadeInWithoutAnimationAction)
    
    case (.Hide, true):
      self.style = style
      run(SKAction.sequence([waitAction, fadeInWithAnimationAction]))
    
    case (.Hide, false):
      self.style = style
      run(fadeInWithAnimationAction)
    
    case (.Sitting(_, _), _):
      run(fadeOutAction) {
        self.style = style
        self.run(self.fadeInWithAnimationAction)
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
  
  func clapWithEyes() {
    run(SKAction.sequence([setClosedEyesTextureAction, waitAction, setFrontTextureAction]))
  }
  
  func upWings() {
    run(raiseWingsTextureAction)
  }
  
  func dowsWings() {
    run(setFrontTextureAction)
  }

  func hide() {
    run(fadeOutAction) {
      self.removeAllActions()
      self.randomStaffIsDoing = false
    }
  }
  
  func doRandomStaff() {
    let waitBefore = SKAction.wait(forDuration: 10, withRange: 10)
    
    let clapWithEyes = SKAction.sequence([setClosedEyesTextureAction, waitAction, setFrontTextureAction])
    let flapWithWings = SKAction.sequence([raiseWingsTextureAction, waitAction, setFrontTextureAction])
    
    let randomAction = SKAction.run({
      self.run(Int.random(in: 0...1) == 0 ? clapWithEyes : flapWithWings)
    })

    let sequence = SKAction.sequence([waitBefore, randomAction])
    self.run(SKAction.repeatForever(sequence))
  }
}

