//
//  TDTaskTextField.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 22.05.2021.
//

import UIKit

class TDTaskTextField: UITextField {

  override func draw(_ rect: CGRect) {
    let bottomBorderLine = CALayer()
    bottomBorderLine.frame = CGRect(x: 0, y: bounds.height.int, width: bounds.width.int, height: 1)
    bottomBorderLine.backgroundColor = UIColor(red: 0.31, green: 0.329, blue: 0.549, alpha: 1).cgColor
    layer.insertSublayer(bottomBorderLine, at: 0)
  }

  init(placeholder: String) {
    super.init(frame: .zero)

    let spacer = UIView()
    spacer.anchor(widthConstant: 12, heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant)
    leftView = spacer
    leftViewMode = .always
    attributedPlaceholder = NSAttributedString(string: placeholder,
                                               attributes: [NSAttributedString.Key.foregroundColor: Style.App.placeholder])
    font = UIFont.systemFont(ofSize: 13, weight: .medium)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
