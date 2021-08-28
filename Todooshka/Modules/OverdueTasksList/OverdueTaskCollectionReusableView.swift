//
//  OverdueTaskCollectionReusableView.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import UIKit

class OverdueTaskCollectionReusableView: UICollectionReusableView {
    
    static var reuseID: String = "OverdueTaskCollectionReusableView"
    
    private let sectionHeaderLabel = UILabel()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        addSubview(sectionHeaderLabel)
        sectionHeaderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        sectionHeaderLabel.textAlignment = .left
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String) {
        sectionHeaderLabel.text = text
    }
}

