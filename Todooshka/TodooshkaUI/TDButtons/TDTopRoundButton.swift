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
  
  func configure(image: UIImage?, blurEffect: Bool) {
    if blurEffect {
      let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
      let blurEffectView = UIVisualEffectView(effect: blurEffect)
      addSubview(blurEffectView)
      blurEffectView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    } else {
      backgroundColor = UIColor(named: "appTopBarButtonBackground")
    }
    
    let imageView = UIImageView(image: image)
    addSubview(imageView)
    
    imageView.tintColor = UIColor(named: "appTopBarButtonTint")
    imageView.anchorCenterXToSuperview()
    imageView.anchorCenterYToSuperview()
  }
  
}

