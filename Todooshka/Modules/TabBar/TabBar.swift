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
  public let tabBarItem1 = UIImageView(image: UIImage(named: "clipboard-tick")?.template)
  public let tabBarItem2 = UIImageView(image: UIImage(named: "user-square")?.template)
  public let addTaskButton = TDAddTaskButton(type: .system)

  private var oldLayer: CALayer?

  override var selectedItem: UITabBarItem? {
    didSet {
      if selectedItem?.tag == 1 {
        tabBarItem1.tintColor = Style.TabBar.Selected
        tabBarItem2.tintColor = Style.TabBar.Unselected
      }
      if selectedItem?.tag == 2 {
        tabBarItem1.tintColor = Style.TabBar.Unselected
        tabBarItem2.tintColor = Style.TabBar.Selected
      }
    }
  }
  // ipad - 49, 83
  // MARK: - Lifecycle
  override func layoutSubviews() {
    super.layoutSubviews()

    // adding
    addSubview(tabBarItem1)
    addSubview(tabBarItem2)
    addSubview(addTaskButton)

    // tabBar
    itemPositioning = .fill
    layer.masksToBounds = false

    // tabBarItem1
    tabBarItem1.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem1.anchorCenterXToSuperview(constant: -1 * bounds.width / 4 - 15 )
    tabBarItem1.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )

    // tabBarItem2
    tabBarItem2.anchor(widthConstant: 24, heightConstant: 24)
    tabBarItem2.anchorCenterXToSuperview(constant: bounds.width / 4 + 15 )
    tabBarItem2.anchorCenterYToSuperview(constant: bounds.height > 50 ? -16 : 0 )

    // addTaskButton
    addTaskButton.anchor(bottom: topAnchor, bottomConstant: -45, widthConstant: 60.0, heightConstant: 60.0)
    addTaskButton.anchorCenterXToSuperview()
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

    path.move(to: CGPoint(x: 0, y: -17)) // start top left
    path.addArc(withCenter: CGPoint(x: 17, y: 17), radius: 17, startAngle: -.pi, endAngle: -.pi / 2, clockwise: true)
    path.addLine(to: CGPoint(x: (centerWidth - plusButtonRadius - 17), y: 0) ) // the beginning of the trough
    path.addArc(withCenter: CGPoint(x: (centerWidth - plusButtonRadius - 17), y: 17), radius: 17, startAngle: -.pi / 2, endAngle: 0, clockwise: true)
    path.addLine(to: CGPoint(x: (centerWidth + plusButtonRadius), y: 17) ) // the beginning of the trough
    path.addArc(withCenter: CGPoint(x: (centerWidth + plusButtonRadius + 17), y: 17), radius: 17, startAngle: -.pi, endAngle: -.pi / 2, clockwise: true)
    path.addLine(to: CGPoint(x: self.frame.width - 17, y: 0))
    path.addArc(withCenter: CGPoint(x: self.frame.width - 17, y: 17), radius: 17, startAngle: -.pi / 2, endAngle: 0, clockwise: true)
    path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
    path.addLine(to: CGPoint(x: 0, y: self.frame.height))
    path.close()

    return path.cgPath
  }

}
