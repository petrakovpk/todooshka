//
//  ThemeCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import UIKit
import Foundation

class ThemeCell: UICollectionViewCell {
  // MARK: - static properties
  static var reuseID: String = "ThemeCell"

  // MARK: - UI Elements
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    return label
  }()

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    cornerRadius = 15

    contentView.addSubviews([
      nameLabel
    ])

    // nameLabel
    nameLabel.anchorCenterXToSuperview()
    nameLabel.anchor(
      bottom: contentView.bottomAnchor,
      bottomConstant: 8,
      widthConstant: Sizes.Cells.ThemeCell.width - 8
    )
    
  }

  // MARK: - UI Elements
  func configure(with theme: Theme) {
    contentView.backgroundColor = Style.Cells.KindOfTask.UnselectedBackground
    nameLabel.text = theme.name
  }
}
