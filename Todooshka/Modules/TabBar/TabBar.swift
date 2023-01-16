//
//  TabBar.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.07.2021.
//
import UIKit

import RxSwift
import RxCocoa
import RxGesture

class TabBar: UITabBar {
  // MARK: - Properties
  public let tabBarItem1 = UIImageView(image: Icon.crown.image.template)
  public let tabBarItem2 = UIImageView(image: Icon.clipboardTick.image.template)
  public let tabBarItem3 = UIImageView(image: Icon.userSquare.image.template)

  public let addTaskButton = TDAddTaskButton(type: .system)

  private var oldLayer: CALayer?

  override var selectedItem: UITabBarItem? {
    didSet {
      switch selectedItem?.tag {
      case 1:
        tabBarItem1.tintColor = Style.TabBar.Selected
        tabBarItem2.tintColor = Style.TabBar.Unselected
        tabBarItem3.tintColor = Style.TabBar.Unselected
      case 2:
        tabBarItem1.tintColor = Style.TabBar.Unselected
        tabBarItem2.tintColor = Style.TabBar.Selected
        tabBarItem3.tintColor = Style.TabBar.Unselected
      case 3:
        tabBarItem1.tintColor = Style.TabBar.Unselected
        tabBarItem2.tintColor = Style.TabBar.Unselected
        tabBarItem3.tintColor = Style.TabBar.Selected
      default:
        return
      }

    }
  }
  // ipad - 49, 83
  // MARK: - Lifecycle
  override func layoutSubviews() {
    super.layoutSubviews()

    // adding
    addSubviews([
      addTaskButton,
      tabBarItem1,
      tabBarItem2,
      tabBarItem3
    ])

    // tabBar
    itemPositioning = .automatic
    layer.masksToBounds = false

    // tabBarItem1
    tabBarItem1.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem1.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + bounds.width / 8 )
    tabBarItem1.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )

    // tabBarItem2
    tabBarItem2.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem2.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + 3 * bounds.width / 8 )
    tabBarItem2.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )

    // tabBarItem3
    tabBarItem3.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem3.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + 5 * bounds.width / 8 )
    tabBarItem3.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )
    
    // addTaskButton
    addTaskButton.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + 7 * bounds.width / 8 )
    addTaskButton.anchorCenterYToSuperview(constant: -22)
    addTaskButton.anchor(
      widthConstant: 60.0,
      heightConstant: 60.0
    )
  }

  override func draw(_ rect: CGRect) {
    traitCollection.userInterfaceStyle == .dark ? drawDarkMode() : drawLightMode()
  }

  // MARK: - Configure UI
  private func drawDarkMode() {
    let shapeLayer = CAShapeLayer()
    let gradientLayer = CAGradientLayer()
    let backgroundLayer = CALayer()

    // shapeLayer
    shapeLayer.path = createPath()

    // gradientLayer
    gradientLayer.locations = [0, 1]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0, y: 1)
    gradientLayer.frame = bounds
    gradientLayer.mask = shapeLayer
    gradientLayer.colors = [
      Style.TabBar.Background!.cgColor,
      Style.TabBar.Background!.withAlphaComponent(0).cgColor
    ]

    // backgroundLayer
    backgroundLayer.frame = bounds
    backgroundLayer.mask = shapeLayer
    backgroundLayer.addSublayer(gradientLayer)
    backgroundLayer.backgroundColor = UIColor.clear.cgColor

    if let oldLayer = oldLayer {
      layer.replaceSublayer(oldLayer, with: backgroundLayer)
    } else {
      layer.insertSublayer(backgroundLayer, at: 0)
    }

    oldLayer = backgroundLayer
  }

  func drawLightMode() {
    // adding
    let shapeLayer = CAShapeLayer()
    let backgroundLayer = CALayer()

    // shapeLayer
    shapeLayer.path = createPath()

    // backgroundLayer
    backgroundLayer.frame = bounds
    backgroundLayer.mask = shapeLayer
    backgroundLayer.backgroundColor = Style.TabBar.Background?.cgColor

    if let oldLayer = oldLayer {
      layer.replaceSublayer(oldLayer, with: backgroundLayer)
    } else {
      layer.insertSublayer(backgroundLayer, at: 0)
    }

    oldLayer = backgroundLayer
  }

  // MARK: - Core Graph
  func createPath() -> CGPath {
    let plusButtonRadius: CGFloat = 30.0
    let path = UIBezierPath()
    let centerWidth = self.frame.width / 2
    let width = self.frame.width

    // start top left minus 17
    path.move(to: CGPoint(x: 0, y: 0))

    // arc left to the button
    path.addArc(
      withCenter: CGPoint(
        x: (7 * bounds.width / 8 - plusButtonRadius - 17),
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
        x: (7 * bounds.width / 8 + plusButtonRadius + 17),
        y: 17
      ),
      radius: 17,
      startAngle: -.pi,
      endAngle: -.pi / 2,
      clockwise: true
    )
    
    // to the right top
    path.addLine(to: CGPoint(x: self.frame.width, y: 0))
    
    // to the right bottom
    path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
    
    // to the left bottom
    path.addLine(to: CGPoint(x: 0, y: self.frame.height))
    
    // we've done it!
    path.close()

    return path.cgPath
  }
}
