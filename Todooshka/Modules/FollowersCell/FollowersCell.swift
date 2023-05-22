//
//  FollowersCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import UIKit

class FollowersCell: UITableViewCell {
  static var reuseID: String = "FollowersCell"
  
  // MARK: - UI Elements
  private let userImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .systemRed.withAlphaComponent(0.2)
    return imageView
  }()
  
  private let userNickLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
    return label
  }()
  
  private let userNameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  // MARK: - Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  func setupUI() {
    let stackView = UIStackView(arrangedSubviews: [userNickLabel, userNameLabel], axis: .vertical)
    stackView.distribution = .fillEqually
    
    backgroundColor = .clear
    
    contentView.addSubviews([
      userImageView,
      stackView
    ])
    
    userImageView.anchorCenterYToSuperview()
    userImageView.cornerRadius = (bounds.height - 4) / 2
    userImageView.anchor(
      left: contentView.leftAnchor,
      leftConstant: 2,
      widthConstant: bounds.height - 4,
      heightConstant: bounds.height - 4
    )
  
    stackView.anchor(
      top: contentView.topAnchor,
      left: userImageView.rightAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor,
      topConstant: 4,
      leftConstant: 4,
      bottomConstant: 4,
      rightConstant: 4
    )
    
  }
  
  func configure(with item: FollowersItem) {
    userImageView.image = item.image
    userNickLabel.text = item.nick
    userNameLabel.text = item.name
  }
  
}
