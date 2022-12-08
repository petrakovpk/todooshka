//
//  ThemeStepCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.


import UIKit
import Foundation

class ThemeStepCell: UICollectionViewCell {
  static var reuseID: String = "ThemeStepCell"
  
  // MARK: - UI Properties
  private let label: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.textAlignment = .center
    return label
  }()

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    cornerRadius = 15
    contentView.backgroundColor = .systemBlue.withAlphaComponent(0.3)

    contentView.addSubviews([
      label
    ])
    
    // label
    label.anchor(
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor,
      leftConstant: 8,
      bottomConstant: 8,
      rightConstant: 8
    )
  }

  // MARK: - UI Elements
  func configure(with step: ThemeStep) {
    label.text = step.goal
  }
}

