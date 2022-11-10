//
//  TDRoundButton.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 29.08.2021.
//

import UIKit

class TDRoundButton: UIButton {
  // MARK: - Draw
  override func draw(_ rect: CGRect) {
    cornerRadius = bounds.width / 2
  }

  // MARK: - Configure
  func configure(image: UIImage?, blurEffect: Bool) {
    // def
    let imageView = UIImageView(image: image)

    // adding
    addSubview(imageView)

    // blurEffect
    if blurEffect {
      let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
      let blurEffectView = UIVisualEffectView(effect: blurEffect)
      addSubview(blurEffectView)
      blurEffectView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    } else {
      backgroundColor = Style.Buttons.RoundButton.background
    }

    // imageView
    imageView.tintColor = Style.Buttons.RoundButton.tint
    imageView.anchorCenterXToSuperview()
    imageView.anchorCenterYToSuperview()
  }
}
