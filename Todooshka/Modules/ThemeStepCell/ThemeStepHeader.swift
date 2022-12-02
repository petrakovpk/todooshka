//
//  ThemeStepHeader.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.
//

import UIKit

class ThemeStepHeader: UICollectionReusableView {
  static var reuseID: String = "ThemeStepHeader"

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

  func configure(with section: ThemeStepSection) {
    label.text = section.header
  }
}

