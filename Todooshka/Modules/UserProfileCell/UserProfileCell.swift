//
//  UserProfileCell.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import UIKit

class UserProfileCell: UITableViewCell {

  // MARK: - Properties
  static var reuseID: String = "UserProfileCell"

  // MARK: - UI Properties
  private let leftTextLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .left
    return label
  }()

  private let rightTextLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    label.textAlignment = .right
    return label
  }()

  // MARK: - Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)

    // adding
    contentView.addSubview(leftTextLabel)
    contentView.addSubview(rightTextLabel)

    // contentView
    contentView.backgroundColor = Style.App.background

    // leftText
    leftTextLabel.anchorCenterYToSuperview()
    leftTextLabel.anchor(left: contentView.leftAnchor, leftConstant: 16)

    // rightText
    rightTextLabel.anchorCenterYToSuperview()
    rightTextLabel.anchor(left: leftTextLabel.rightAnchor, right: contentView.rightAnchor, leftConstant: 16, rightConstant: 16)
  }

  // MARK: - Configure
  func configure(leftText: String, rightText: String ) {
    leftTextLabel.text = leftText
    rightTextLabel.text = rightText
  }
}
