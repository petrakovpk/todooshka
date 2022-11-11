//
//  AddThemeCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 10.11.2022.
//

import UIKit
import Foundation

class ThemePlusButtonCell: UICollectionViewCell {
  static var reuseID: String = "ThemePlusButtonCell"
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    cornerRadius = 15
    contentView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
    
    contentView.addSubviews([
      
    ])

  }
}
