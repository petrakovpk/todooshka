//
//  SKBirdNode.swift
//  Todooshka
//
//  Created by Pavel Petakov on 03.08.2022.
//


import SpriteKit

class SKBirdNode: SKSpriteNode {
 
  // MARK: - Actions
  private let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
  private let fadeInAction = SKAction.fadeIn(withDuration: 0)
  
  // MARK: - Properties
  let clade: Clade
  let style: Style
  
  private let hatchingPositionData: [Int: CGPoint] = [
    1: CGPoint(x: -30, y: 20),
    2: CGPoint(x: 20, y: 20),
    3: CGPoint(x: 70, y: -5),
    4: CGPoint(x: 35, y: -35),
    5: CGPoint(x: -5, y: -40),
    6: CGPoint(x: -45, y: -35),
    7: CGPoint(x: -80, y: -5)
  ]
  
  private let sittingPositionData: [Int: CGPoint] = [
    1: CGPoint(x: 150, y: 0),
    2: CGPoint(x: -150, y: 0),
    3: CGPoint(x: 100, y: 0),
    4: CGPoint(x: -100, y: 0),
    5: CGPoint(x: 50, y: 0),
    6: CGPoint(x: -60, y: 0),
    7: CGPoint(x: 0, y: 0)
  ]
  
  public var hatchingPosition: CGPoint {
    hatchingPositionData[clade.eggN] ?? CGPoint(x: 0, y: 0)
  }
  
  public var sittingPosition: CGPoint {
    sittingPositionData[clade.eggN] ?? CGPoint(x: 0, y: 0)
  }
  
  private var normalImage: UIImage? {
    UIImage(named: clade.rawValue + "_" + style.rawValue + "_" + BirdState.Normal.rawValue)
  }
  
  private var rightLegForwardImage: UIImage? {
    UIImage(named: clade.rawValue + "_" + style.rawValue + "_" + BirdState.RightLegForward.rawValue)
  }
  
  private var leftLegForwardImage: UIImage? {
    UIImage(named: clade.rawValue + "_" + style.rawValue + "_" + BirdState.LeftLegForward.rawValue)
  }
  
  // MARK: - Init
  init(clade: Clade, style: Style) {
    self.clade = clade
    self.style = style
    super.init(texture: nil, color: .clear, size: .zero)
    
    name = "Bird"
    alpha = 0.0
    xScale = Theme.Scene.Egg.scale
    yScale = Theme.Scene.Egg.scale
    zPosition = CGFloat(clade.eggN + 1)
    
    guard let normalImage = normalImage else { return }
    
    size = SKTexture(image: normalImage).size()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Actions
  func hatchAndRunToTheRight() {
    
    guard let normalImage = normalImage,
          let rightLegForwardImage = rightLegForwardImage,
          let leftLegForwardImage = leftLegForwardImage else { return }

    // actions
    let animateAction = SKAction.repeatForever(SKAction.animate(with: [SKTexture(image: rightLegForwardImage), SKTexture(image: leftLegForwardImage)], timePerFrame: 0.3, resize: true, restore: false))
    let hatchAction = SKAction.setTexture(SKTexture(image: normalImage), resize: true)
    let runAction = SKAction.move(to: CGPoint(x: UIScreen.main.bounds.width + 50, y: position.y), duration: 4.0)
    let waitAction = SKAction.wait(forDuration: 0.5)
    
    // sequence
    let animateSequence = SKAction.sequence([waitAction, hatchAction, fadeInAction, animateAction])
    let runSequence = SKAction.sequence([waitAction, waitAction, runAction])
    
    // run
    run(animateSequence)
    run(runSequence)
  }
  
  func run(withDelay: Bool, toPosition: CGPoint, completion: @escaping () -> Void ) {
    
    guard let normalImage = normalImage,
          let rightLegForwardImage = rightLegForwardImage,
          let leftLegForwardImage = leftLegForwardImage else { return }
    
    let velocity = 91.0
    let space = UIScreen.main.bounds.width / 2 + sittingPosition.x
    let duration = space / velocity
    
    // actions
    let animateAction = SKAction.repeatForever(SKAction.animate(with: [SKTexture(image: rightLegForwardImage), SKTexture(image: leftLegForwardImage)], timePerFrame: 0.3, resize: true, restore: false))
    let runAction = SKAction.move(to: toPosition, duration: duration)
    let waitAction = SKAction.wait(forDuration: withDelay ? 4.5 : 0.1)
    
    // sequence
    let animateSequence = withDelay ? SKAction.sequence([waitAction, fadeInAction, animateAction]) : SKAction.sequence([waitAction, animateAction])
    let runSequence = SKAction.sequence([waitAction, runAction])
    
    alpha = 1.0

    // running
    run(animateSequence)
    run(runSequence) {
      self.removeAllActions()
      self.run(SKAction.setTexture(SKTexture(image: normalImage), resize: true))
      completion()
    }
  }
  
}

