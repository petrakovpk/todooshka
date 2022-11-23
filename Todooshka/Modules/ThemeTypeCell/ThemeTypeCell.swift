//
//  ThemeTypeCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 21.11.2022.
//

import UIKit
import Foundation

class ThemeTypeCell: UICollectionViewCell {
  static var reuseID: String = "ThemeTypeCell"
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
    label.textAlignment = .center
    return label
  }()

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    cornerRadius = 15
    contentView.backgroundColor = .systemRed.withAlphaComponent(0.3)

    contentView.addSubviews([
      titleLabel
    ])
    
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(
        bottom: contentView.bottomAnchor,
        bottomConstant: 4,
        widthConstant: Sizes.Cells.ThemeTypeCell.width - 8
      )
  }

  // MARK: - UI Elements
  func configure(with item: ThemeTypeItem) {
    titleLabel.text = item.type.rawValue
  }
}

