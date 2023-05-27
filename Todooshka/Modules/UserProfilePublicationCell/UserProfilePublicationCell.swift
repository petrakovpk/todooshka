//
//  UserProfilePublicationCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 01.05.2023.
//

import UIKit

class UserProfilePublicationCell: UICollectionViewCell {
  static var reuseID: String = "UserProfilePublicationCell"
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private let viewsLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.textColor = .white
    return label
  }()

  override func draw(_ rect: CGRect) {
    super.draw(rect)

    contentView.addSubviews([
      imageView,
      viewsLabel
    ])
    
    imageView.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor
    )
    
    viewsLabel.anchor(
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor,
      bottomConstant: 8,
      rightConstant: 8
    )
  }

  // MARK: - UI Elements
  func configure(with item: UserProfilePublicationItem) {
    if item.publication.isPublic {
      imageView.image = item.publicationImage?.image
    } else {
      imageView.image = item.publicationImage?.image.tint(.clear, blendMode: .normal, alpha: 0.5)
    }
    
    viewsLabel.text = item.viewsCount.string
  }
}


