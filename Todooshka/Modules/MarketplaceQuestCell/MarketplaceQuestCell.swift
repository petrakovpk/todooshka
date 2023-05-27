//
//  ThemeCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import UIKit
import Foundation

class MarketplaceQuestCell: UICollectionViewCell {
  static var reuseID: String = "MaketplaceQuestCell"

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private let nameLabelContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
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
    contentView.backgroundColor = Style.Cells.Kind.UnselectedBackground
    
    contentView.addSubviews([
      imageView,
      nameLabelContainerView
    ])
    
    nameLabelContainerView.addSubviews([
      nameLabel
    ])
    
    imageView.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor
    )

    nameLabelContainerView.anchor(
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor,
      heightConstant: 30
    )
    
    nameLabel.anchor(
      top: nameLabelContainerView.topAnchor,
      left: nameLabelContainerView.leftAnchor,
      bottom: nameLabelContainerView.bottomAnchor,
      right: nameLabelContainerView.rightAnchor
    )
    
  }

  // MARK: - UI Elements
  func configure(with item: MarketplaceQuestSectionItem) {
    imageView.image = item.quest.previewImage
    nameLabel.text = item.quest.name
  }
}
