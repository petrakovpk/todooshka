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
    
    init(){
        super.init(frame: .zero)
        
        let spacer = UIView()
        spacer.anchor(widthConstant: 12, heightConstant: 40)
        leftView = spacer
        leftViewMode = .always
        returnKeyType = .done

        attributedPlaceholder = NSAttributedString(string: "Введите название задачи",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "taskPlaceholderText")])
        font = UIFont.systemFont(ofSize: 13, weight: .medium)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
