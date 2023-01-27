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
  public let tabBarItem3 = UIImageView(image: Icon.userSquare.image.template)

  private let shapeLayer = CAShapeLayer()
  private let gradientLayer = CAGradientLayer()
  private let backgroundLayer = CALayer()
  
  private var oldBackgroundLayer: CALayer?

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
  
  override func layoutSubviews() {
    super.layoutSubviews()

    addSubviews([
      addTaskButton,
      tabBarItem1,
      tabBarItem2,
      tabBarItem3
    ])

    backgroundColor = Style.App.background
    itemPositioning = .automatic
    layer.masksToBounds = false

    tabBarItem1.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem1.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + bounds.width / 8 )
    tabBarItem1.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )

    tabBarItem2.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem2.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + 3 * bounds.width / 8 )
    tabBarItem2.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )

    tabBarItem3.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem3.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + 5 * bounds.width / 8 )
    tabBarItem3.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )
    
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

  private func drawDarkMode() {
    shapeLayer.path = createPath()

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
