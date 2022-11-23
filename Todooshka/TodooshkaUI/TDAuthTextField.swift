//
//  TDAuthTextField.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit

class TDAuthTextField: UITextField {
  let imageView = UIImageView()

  init(type: AuthTextFieldType) {
    super.init(frame: .zero)

    // properties
    let spacer = UIView()

    // adding
    spacer.addSubview(imageView)

    // contentView
    borderWidth = 1.0
    cornerRadius = 13
    leftView = spacer
    leftViewMode = .always
    returnKeyType = .done
    borderColor = Style.TextFields.AuthTextField.Border
    backgroundColor = Style.TextFields.AuthTextField.Background

    // spacer
    spacer.anchor(widthConstant: 54, heightConstant: 54)

    // imageView
    imageView.tintColor = UIColor(red: 0.337, green: 0.345, blue: 0.42, alpha: 1)
    imageView.anchorCenterXToSuperview()
    imageView.anchorCenterYToSuperview()

    // type
    switch type {
    case .email:
      placeholder = "Email"
      returnKeyType = .done
      imageView.image = Icon.sms.image.template
    case .password:
      isSecureTextEntry = true
      placeholder = "Password"
      returnKeyType = .done
      imageView.image = Icon.lock.image.template
    case .repeatPassword:
      isSecureTextEntry = true
      placeholder = "Repeat password"
      returnKeyType = .done
      imageView.image = Icon.lock.image.template
    case .phone:
      keyboardType = .numberPad
      placeholder = "+X (XXX) XXX XX XX"
      imageView.image = Icon.call.image.template
    case .otp:
      keyboardType = .numberPad
      placeholder = "Code"
      imageView.image = Icon.lock.image.template
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
