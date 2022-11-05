//
//  ShopCollectionViewHeader.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import UIKit

class ShopCollectionViewHeader: UICollectionReusableView {

  // MARK: - Properties
  static var reuseID: String = "TaskListCollectionReusableView"

  // MARK: - UI Elements
  public let label: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    return label
  }()

  // MARK: - draw
  override func draw(_ rect: CGRect) {
    addSubview(label)
    label.anchorCenterYToSuperview()
    label.anchor(left: leftAnchor, leftConstant: 16)
  }
}
