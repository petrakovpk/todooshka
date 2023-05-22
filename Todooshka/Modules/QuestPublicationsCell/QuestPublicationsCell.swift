//
//  QuestUserResultCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 15.05.2023.
//

import UIKit

class QuestPublicationsCell: UICollectionViewCell {
  static var reuseID: String = "QuestPublicationsCell"
  
  private var userResultImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = Palette.SingleColors.Portage.withAlphaComponent(0.3)
    return imageView
  }()
  
  override func draw(_ rect: CGRect) {
    contentView.cornerRadius = 11
    contentView.backgroundColor = .clear
    
    contentView.addSubviews([
      userResultImageView
    ])
    
    userResultImageView.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor
    )
  }
  
  func configure(with item: QuestPublicationsSectionItem) {
    userResultImageView.image = item.publicationImage.image
  }
}



