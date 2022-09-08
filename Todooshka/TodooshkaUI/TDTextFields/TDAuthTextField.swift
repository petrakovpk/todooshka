//
//  TDAuthTextField.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit

class TDAuthTextField: UITextField {
  
  init(customPlaceholder: String, imageName: String){
    super.init(frame: .zero)
    
    // properties
    let spacer = UIView()
    let imageView = UIImageView(image: UIImage(named: imageName)?.template)
    
    // adding
    spacer.addSubview(imageView)
    
    // contentView
    borderWidth = 1.0
    cornerRadius = 13
    leftView = spacer
    leftViewMode = .always
    returnKeyType = .done
    placeholder = customPlaceholder
    borderColor = Palette.DualColors.HawkesBlue_Haiti_7_9_30
    backgroundColor = Palette.DualColors.TitanWhite_224_226_255_
    
    // spacer
    spacer.anchor(widthConstant: 54, heightConstant: 54)
    
    // imageView
    imageView.tintColor = UIColor(red: 0.337, green: 0.345, blue: 0.42, alpha: 1)
    imageView.anchorCenterXToSuperview()
    imageView.anchorCenterYToSuperview()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
