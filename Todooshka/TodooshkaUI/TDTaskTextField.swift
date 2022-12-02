//
//  TDTaskTextField.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 22.05.2021.
//

import UIKit

class TDTaskTextField: UITextField {
  private let bottomBorderLineLayer: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = UIColor(red: 0.31, green: 0.329, blue: 0.549, alpha: 1).cgColor
    return layer
  }()
  
  private let spacer = UIView()
  
  override func draw(_ rect: CGRect) {
    bottomBorderLineLayer.frame = CGRect(x: 0, y: bounds.height.int, width: bounds.width.int, height: 1)
    layer.insertSublayer(bottomBorderLineLayer, at: 0)
  }
  
  init(placeholder: String) {
    super.init(frame: .zero)
    attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [NSAttributedString.Key.foregroundColor: Style.App.placeholder])
    font = UIFont.systemFont(ofSize: 13, weight: .medium)
    leftView = spacer
    leftViewMode = .always
    
    // spacer
    spacer.anchor(widthConstant: 12, heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
