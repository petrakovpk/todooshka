//
//  KindListReusableCell..swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 12.09.2021.
//

import UIKit

class KindListReusableCell: UICollectionReusableView {
  static let reuseID: String = "KindListReusableCell"

  private let headerLabel = UILabel()

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)

    // adding
    addSubview(headerLabel)

    // headerLabel
    headerLabel.textAlignment = .left
    headerLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    headerLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(text: String) {
    headerLabel.text = text
  }
}
