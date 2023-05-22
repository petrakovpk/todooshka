//
//  TabBar.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.07.2021.
//

import RxSwift
import RxCocoa
import RxGesture
import UIKit


class TabBar: UITabBar {
  public let addTaskButton = TDAddTaskButton(type: .system)
  public let tabBarItem1 = UIImageView(image: Icon.crown.image.template)
  public let tabBarItem2 = UIImageView(image: Icon.clipboardTick.image.template)
  public let tabBarItem4 = UIImageView(image: Icon.userSquare.image.template)
  public let tabBarItem5 = UIImageView(image: Icon.userSquare.image.template)

  private let shapeLayer = CAShapeLayer()
  private let gradientLayer = CAGradientLayer()
  private let backgroundLayer = CALayer()
  
  private var oldBackgroundLayer: CALayer?
  
  func configureUI() {
    addSubviews([
      addTaskButton
    ])

    backgroundColor = Style.App.background
    itemPositioning = .automatic
    layer.masksToBounds = false

    addTaskButton.anchorCenterXToSuperview()
    addTaskButton.anchorCenterYToSuperview(constant: -22)
    addTaskButton.anchor(
      widthConstant: 60.0,
      heightConstant: 60.0
    )
  }

  override func draw(_ rect: CGRect) {
    traitCollection.userInterfaceStyle == .dark ? drawDarkMode() : drawLightMode()
    configureUI()
  }

  private func drawDarkMode() {
    shapeLayer.path = createPath()

    gradientLayer.isHidden = false
    gradientLayer.locations = [0, 1]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0, y: 1)
    gradientLayer.frame = bounds
    gradientLayer.mask = shapeLayer
    gradientLayer.colors = [
      Style.TabBar.Background!.cgColor,
      Style.TabBar.Background!.withAlphaComponent(0).cgColor
    ]

    backgroundLayer.frame = bounds
    backgroundLayer.mask = shapeLayer
    backgroundLayer.addSublayer(gradientLayer)
    backgroundLayer.backgroundColor = UIColor.clear.cgColor

    if let oldLayer = oldBackgroundLayer {
      layer.replaceSublayer(oldLayer, with: backgroundLayer)
    } else {
      layer.insertSublayer(backgroundLayer, at: 0)
    }

    oldBackgroundLayer = backgroundLayer
  }

  func drawLightMode() {
    shapeLayer.path = createPath()

    gradientLayer.isHidden = true
    backgroundLayer.frame = bounds
    backgroundLayer.mask = shapeLayer
    backgroundLayer.backgroundColor = Style.TabBar.Background?.cgColor

    if let oldLayer = oldBackgroundLayer {
      layer.replaceSublayer(oldLayer, with: backgroundLayer)
    } else {
      layer.insertSublayer(backgroundLayer, at: 0)
    }

    oldBackgroundLayer = backgroundLayer
  }

  func createPath() -> CGPath {
    let plusButtonRadius: CGFloat = 30.0
    let path = UIBezierPath()
    let centerWidth = self.frame.width / 2
    let width = self.frame.width

    // start top left (0, 17)
    path.move(to: CGPoint(x: 0, y: -17))
    
    // add arc to (17,0)
    path.addArc(
      withCenter: CGPoint(
        x: 17,
        y: 17
      ),
      radius: 17,
      startAngle: -.pi,
      endAngle: -.pi / 2,
      clockwise: true
    )

    // arc left to the button
    path.addArc(
      withCenter: CGPoint(
        x: (centerWidth - plusButtonRadius - 17),
        y: 17
      ),
      radius: 17,
      startAngle: -.pi / 2,
      endAngle: 0,
      clockwise: true
    )

    // arc right to the button
    path.addArc(
      withCenter: CGPoint(
        x: (centerWidth + plusButtonRadius + 17),
        y: 17
      ),
      radius: 17,
      startAngle: -.pi,
      endAngle: -.pi / 2,
      clockwise: true
    )

    // arc right to the frame
    path.addArc(
      withCenter: CGPoint(
        x: self.frame.width - 17,
        y: 17),
      radius: 17,
      startAngle: -.pi / 2,
      endAngle: 0,
      clockwise: true
    )

    // to the right bottom
    path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))

    // to the left bottom
    path.addLine(to: CGPoint(x: 0, y: self.frame.height))
    
    // we've done it!
    path.close()

    return path.cgPath
  }
}
