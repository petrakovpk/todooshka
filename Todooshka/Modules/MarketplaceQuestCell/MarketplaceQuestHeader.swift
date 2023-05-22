//
//  ThemeHeader.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.11.2022.
//

import UIKit

class MarketplaceQuestHeader: UICollectionReusableView {
  static var reuseID: String = "DealHeader"

  // MARK: - UI elements
  private let label: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    return label
  }()

  // MARK: - draw
  override func draw(_ rect: CGRect) {
    if label.isDescendant(of: self) {
      label.removeFromSuperview()
    }

    // adding
    addSubview(label)

    // label
    label.anchor(
      top: topAnchor,
      left: leftAnchor,
      bottom: bottomAnchor,
      right: rightAnchor,
      leftConstant: 16,
      rightConstant: 16
    )
  }

  func configure(with section: MarketplaceQuestSection) {
    label.text = section.header
  }
}
