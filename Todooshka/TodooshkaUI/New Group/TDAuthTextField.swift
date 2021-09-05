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

        borderWidth = 1.0
        cornerRadius = 13

        let spacer = UIView()
        spacer.anchor(widthConstant: 54, heightConstant: 54)
        
        let imageView = UIImageView(image: UIImage(named: imageName)?.template)
        imageView.tintColor = UIColor(red: 0.337, green: 0.345, blue: 0.42, alpha: 1)
        
        spacer.addSubview(imageView)
        imageView.anchorCenterXToSuperview()
        imageView.anchorCenterYToSuperview()
        
        leftView = spacer
        leftViewMode = .always
        returnKeyType = .done
        placeholder = customPlaceholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
