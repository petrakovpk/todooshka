//
//  TDAddTaskButton.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.08.2021.
//

import UIKit

class TDAddTaskButton: UIButton {
  override func draw(_ rect: CGRect) {
    layer.shadowOffset = CGSize(width: 0, height: 4.0)
    layer.shadowOpacity = 1.0
    layer.shadowRadius = 18.0
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2).cgPath

    layer.shadowColor = Palette.SingleColors.BlueRibbon.cgColor
    layer.backgroundColor = Palette.SingleColors.BlueRibbon.cgColor

    let imageView = UIImageView(image: UIImage(named: "plus"))
    addSubview(imageView)
    imageView.anchorCenterXToSuperview()
    imageView.anchorCenterYToSuperview()

    cornerRadius = bounds.width / 2
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    layer.shadowColor = Palette.SingleColors.Orange.cgColor
    layer.backgroundColor = Palette.SingleColors.Orange.cgColor
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    layer.shadowColor = Palette.SingleColors.BlueRibbon.cgColor
    layer.backgroundColor = Palette.SingleColors.BlueRibbon.cgColor
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    layer.shadowColor = Palette.SingleColors.BlueRibbon.cgColor
    layer.backgroundColor = Palette.SingleColors.BlueRibbon.cgColor
  }
}
