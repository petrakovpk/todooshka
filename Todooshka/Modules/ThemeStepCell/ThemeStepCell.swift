//
//  ThemeStepCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.


import UIKit
import Foundation

class ThemeStepCell: UICollectionViewCell {
  static var reuseID: String = "ThemeStepCell"

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    cornerRadius = 15
    contentView.backgroundColor = .systemBlue.withAlphaComponent(0.3)

    contentView.addSubviews([
      
    ])
  }

  // MARK: - UI Elements
  func configure(with step: ThemeStep) {
 
  }
}

