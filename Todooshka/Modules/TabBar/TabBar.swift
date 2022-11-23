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
  public let tabBarItem1 = UIImageView(image: Icon.home2.image.template)
  public let tabBarItem2 = UIImageView(image: Icon.bookSaved.image.template)
  public let tabBarItem4 = UIImageView(image: Icon.clipboardTick.image.template)
  public let tabBarItem5 = UIImageView(image: Icon.userSquare.image.template)

  public let addTaskButton = TDAddTaskButton(type: .system)

  private var oldLayer: CALayer?

  override var selectedItem: UITabBarItem? {
    didSet {
      switch selectedItem?.tag {
      case 1:
        tabBarItem1.tintColor = Style.TabBar.Selected
        tabBarItem2.tintColor = Style.TabBar.Unselected
        tabBarItem4.tintColor = Style.TabBar.Unselected
        tabBarItem5.tintColor = Style.TabBar.Unselected
      case 2:
        tabBarItem1.tintColor = Style.TabBar.Unselected
        tabBarItem2.tintColor = Style.TabBar.Selected
        tabBarItem4.tintColor = Style.TabBar.Unselected
        tabBarItem5.tintColor = Style.TabBar.Unselected
      case 4:
        tabBarItem1.tintColor = Style.TabBar.Unselected
        tabBarItem2.tintColor = Style.TabBar.Unselected
        tabBarItem4.tintColor = Style.TabBar.Selected
        tabBarItem5.tintColor = Style.TabBar.Unselected
      case 5:
        tabBarItem1.tintColor = Style.TabBar.Unselected
        tabBarItem2.tintColor = Style.TabBar.Unselected
        tabBarItem4.tintColor = Style.TabBar.Unselected
        tabBarItem5.tintColor = Style.TabBar.Selected
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
      tabBarItem4,
      tabBarItem5
    ])

    // tabBar
    itemPositioning = .automatic
    layer.masksToBounds = false

    // tabBarItem1
    tabBarItem1.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem1.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + bounds.width / 10 )
    tabBarItem1.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )

    // tabBarItem2
    tabBarItem2.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem2.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + 3 * bounds.width / 10 )
    tabBarItem2.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )

    // tabBarItem4
    tabBarItem4.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem4.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + 7 * bounds.width / 10 )
    tabBarItem4.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )
    
    // tabBarItem5
    tabBarItem5.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem5.anchorCenterXToSuperview(constant: -1 * bounds.width / 2 + 9 * bounds.width / 10 )
    tabBarItem5.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )

    // addTaskButton
    addTaskButton.anchorCenterXToSuperview()
    addTaskButton.anchor(
      top: topAnchor,
     // right: rightAnchor,
      topConstant: -20,
     // rightConstant: 16,
      widthConstant: 60.0,
      heightConstant: 60.0
    )
  }

  override func draw(_ rect: CGRect) {
    if traitCollection.userInterfaceStyle == .dark {
      drawDarkMode()
    } else {
      drawLightMode()
    }
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
    path.move(to: CGPoint(x: 0, y: 17))
    
    // first arc
    path.addArc(
      withCenter: CGPoint(x: 17, y: 17),
      radius: 17,
      startAngle: -.pi,
      endAngle: -.pi / 2,
      clockwise: true
    )
    
    // second arc left to the button
    path.addArc(
      withCenter: CGPoint(
        x: (width / 2 - plusButtonRadius - 17),
        y: 17
      ),
      radius: 17,
      startAngle: -.pi / 2,
      endAngle: 0,
      clockwise: true
    )
    
    // third arc right to the button
    path.addArc(
      withCenter: CGPoint(
        x: (width / 2 + plusButtonRadius + 17),
        y: 17
      ),
      radius: 17,
      startAngle: -.pi,
      endAngle: -.pi / 2,
      clockwise: true
    )
    
    // fourth arc top rigth corner
    path.addArc(
      withCenter: CGPoint(
        x: width - 17,
        y: 17
      ),
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
