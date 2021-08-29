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
    
    //MARK: - Properties
    private let tabBarItem1 = UIImageView(image: UIImage(named: "clipboard-tick"))
    private let tabBarItem2 = UIImageView(image: UIImage(named: "user-square"))
    
    public let addTaskButton = TDAddTaskButton(type: .custom)
    
    let disposeBag = DisposeBag()
    
    override var selectedItem: UITabBarItem? {
        didSet {
            if selectedItem?.tag == 1 {
                tabBarItem1.alpha = 1
                tabBarItem2.alpha = 0.3
            }
            if selectedItem?.tag == 2 {
                tabBarItem1.alpha = 0.3
                tabBarItem2.alpha = 1
            }
        }
    }
    
    //MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemPositioning = .fill
        
        addSubview(tabBarItem1)
        tabBarItem1.anchor(widthConstant: 24, heightConstant: 24)
        tabBarItem1.anchorCenterXToSuperview(constant: -1 * bounds.width / 4 - 15 )
        tabBarItem1.anchorCenterYToSuperview(constant: -16)

        addSubview(tabBarItem2)
        tabBarItem2.anchor(widthConstant: 24, heightConstant: 24)
        tabBarItem2.anchorCenterXToSuperview(constant: bounds.width / 4 + 15 )
        tabBarItem2.anchorCenterYToSuperview(constant: -16)
        
        addSubview(addTaskButton)
        addTaskButton.anchor(bottom: topAnchor, bottomConstant: -45, widthConstant: 60.0, heightConstant: 60.0)
        addTaskButton.anchorCenterXToSuperview()
    }
    
    override func draw(_ rect: CGRect) {
        self.addShape()
    }
    
    //MARK: - Configure UI
    private func addShape() {
        tintColor = .white
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.074, green: 0.09, blue: 0.217, alpha: 1).cgColor,
            UIColor(red: 0.074, green: 0.09, blue: 0.217, alpha: 0).cgColor
        ]
        gradientLayer.locations = [0,1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        gradientLayer.frame = bounds
        gradientLayer.mask = shapeLayer
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = bounds
        backgroundLayer.mask = shapeLayer
        
        backgroundLayer.addSublayer(gradientLayer)
        layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    //MARK: - Core Graph
    func createPath() -> CGPath {
        let plusButtonRadius: CGFloat = 30.0
        let path = UIBezierPath()
        let centerWidth = self.frame.width / 2
        
        path.move(to: CGPoint(x: 0, y: -17)) // start top left
        path.addArc(withCenter: CGPoint(x: 17, y: 17), radius: 17, startAngle: -.pi , endAngle: -.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: (centerWidth - plusButtonRadius - 17), y: 0) ) // the beginning of the trough
        path.addArc(withCenter: CGPoint(x: (centerWidth - plusButtonRadius - 17), y: 17), radius: 17, startAngle: -.pi / 2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: (centerWidth + plusButtonRadius), y: 17) ) // the beginning of the trough
        path.addArc(withCenter: CGPoint(x: (centerWidth + plusButtonRadius + 17), y: 17), radius: 17, startAngle: -.pi, endAngle: -.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: self.frame.width - 17, y: 0))
        path.addArc(withCenter: CGPoint(x: self.frame.width - 17, y: 17), radius: 17, startAngle: -.pi / 2 , endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()
        
        return path.cgPath
    }
    
}
