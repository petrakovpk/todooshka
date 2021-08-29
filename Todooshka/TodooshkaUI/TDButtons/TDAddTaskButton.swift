//
//  TDAddTaskButton.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.08.2021.
//

import UIKit

class TDAddTaskButton: UIButton {
    
    override func draw(_ rect: CGRect) {
    
        layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 18.0
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        
        layer.shadowColor = Style.blueRibbon.cgColor
        layer.backgroundColor = Style.blueRibbon.cgColor
        
        let imageView = UIImageView(image: UIImage(named: "plus"))
        addSubview(imageView)
        imageView.anchorCenterXToSuperview()
        imageView.anchorCenterYToSuperview()
        
        cornerRadius = bounds.width / 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        layer.shadowColor = Style.internationalOrange.cgColor
        layer.backgroundColor = Style.internationalOrange.cgColor
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        layer.shadowColor = Style.blueRibbon.cgColor
        layer.backgroundColor = Style.blueRibbon.cgColor
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        layer.shadowColor = Style.blueRibbon.cgColor
        layer.backgroundColor = Style.blueRibbon.cgColor
    }
    
}
