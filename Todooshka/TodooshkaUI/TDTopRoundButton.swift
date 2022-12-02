//
//  TDRoundButton.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 29.08.2021.
//

import UIKit

class TDRoundButton: UIButton {
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    cornerRadius = bounds.width / 2
  }
  
  func configure(with image: UIImage) {
    backgroundColor = Style.Buttons.RoundButton.background
    setImage(image, for: .normal)
    tintColor = Style.Buttons.RoundButton.tint
  }
}
