//
//  TDAuthTextField.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit

class TDAuthTextField: UITextField {
  
  let imageView = UIImageView()
  
  init(type: AuthTextFieldType){
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
    case .Email:
      placeholder = "Email"
      returnKeyType = .done
      imageView.image = UIImage(named: "sms")?.template
    case .Password:
      isSecureTextEntry = true
      placeholder = "Password"
      returnKeyType = .done
      imageView.image = UIImage(named: "lock")?.template
    case .RepeatPassword:
      isSecureTextEntry = true
      placeholder = "Repeat password"
      returnKeyType = .done
      imageView.image = UIImage(named: "lock")?.template
    case .Phone:
      keyboardType = .numberPad
      placeholder = "+X (XXX) XXX XX XX"
      imageView.image = UIImage(named: "call")?.template
    case .OTPCode:
      keyboardType = .numberPad
      placeholder = "Code"
      imageView.image = UIImage(named: "lock")?.template
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
