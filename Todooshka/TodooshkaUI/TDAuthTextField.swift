//
//  TDAuthTextField.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit

class TDAuthTextField: UITextField {
  private let leftImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = Style.TextFields.SettingsTextField.Tint
    return imageView
  }()
  
  private let spacer = UIView()
  
  init(type: AuthTextFieldType) {
    super.init(frame: .zero)
    
    // contentView
    backgroundColor = Style.TextFields.AuthTextField.Background
    borderColor = Style.TextFields.AuthTextField.Border
    borderWidth = 1.0
    cornerRadius = 13
    leftView = spacer
    leftViewMode = .always
    returnKeyType = .done
    
    // spacer
    spacer.addSubview(leftImageView)
    spacer.anchor(widthConstant: 54, heightConstant: 54)
    
    // leftImageView
    leftImageView.anchorCenterXToSuperview()
    leftImageView.anchorCenterYToSuperview()
    
    // type
    switch type {
    case .email:
      placeholder = "Email"
      returnKeyType = .done
      leftImageView.image = Icon.sms.image.template
    case .password:
      isSecureTextEntry = true
      placeholder = "Password"
      returnKeyType = .done
      leftImageView.image = Icon.lock.image.template
    case .repeatPassword:
      isSecureTextEntry = true
      placeholder = "Repeat password"
      returnKeyType = .done
      leftImageView.image = Icon.lock.image.template
    case .phone:
      keyboardType = .numberPad
      placeholder = "+X (XXX) XXX XX XX"
      leftImageView.image = Icon.call.image.template
    case .otp:
      keyboardType = .numberPad
      placeholder = "Code"
      leftImageView.image = Icon.lock.image.template
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
