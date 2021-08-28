//
//  UIButtonStyleExtension.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 25.07.2021.
//
import UIKit

extension UIButton {
    public func configureAsAddTaskButton() {
        backgroundColor = .white
        
        let shadows = UIView()
        shadows.frame = frame
        shadows.clipsToBounds = false
        addSubview(shadows)
        
        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 0)
        let layer0 = CALayer()
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = UIColor(red: 0, green: 0.34, blue: 1, alpha: 1).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 18
        layer0.shadowOffset = CGSize(width: 0, height: 4)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        shadows.layer.addSublayer(layer0)
    
        let shapes = UIView()
        shapes.frame = frame
        shapes.clipsToBounds = true
        addSubview(shapes)

        let layer1 = CALayer()
        layer1.backgroundColor = UIColor(red: 0, green: 0.34, blue: 1, alpha: 1).cgColor
        layer1.bounds = shapes.bounds
        layer1.position = shapes.center
        shapes.layer.addSublayer(layer1)
        
        translatesAutoresizingMaskIntoConstraints = false
    }
}
