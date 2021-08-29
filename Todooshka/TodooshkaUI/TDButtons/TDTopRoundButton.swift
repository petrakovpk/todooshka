//
//  TDTopRoundButton.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 29.08.2021.
//

import UIKit

class TDTopRoundButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        cornerRadius = bounds.width / 2
    }

    init(image: UIImage?) {
        super.init(frame: .zero)
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        addSubview(blurEffectView)
        blurEffectView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        let imageView = UIImageView(image: image)
        addSubview(imageView)
        
        imageView.anchorCenterXToSuperview()
        imageView.anchorCenterYToSuperview()
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

