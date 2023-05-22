//
//  QuestImageCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.05.2023.
//

import UIKit

class QuestImageCell: UICollectionViewCell {
  static var reuseID: String = "QuestImageCell"

  private var addPhotoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = Icon.camera.image
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private var userPhotoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = Palette.SingleColors.Portage.withAlphaComponent(0.3)
    return imageView
  }()

  override func draw(_ rect: CGRect) {
    contentView.cornerRadius = 11

    contentView.addSubviews([
      addPhotoImageView,
      userPhotoImageView
    ])
    
    addPhotoImageView.anchorCenterXToSuperview()
    addPhotoImageView.anchorCenterYToSuperview()
    addPhotoImageView.anchor(
      widthConstant: 30,
      heightConstant: 30
    )
    
    userPhotoImageView.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor
    )

  }

  func configure(with item: QuestImageItem) {
    switch item {
    case .addPhoto:
      contentView.backgroundColor = Palette.SingleColors.Portage.withAlphaComponent(0.3)
      userPhotoImageView.image = nil
      userPhotoImageView.isHidden = true
      addPhotoImageView.isHidden = false
    case .questImage(let questImage):
      contentView.backgroundColor = .clear
      userPhotoImageView.image = questImage.image
      userPhotoImageView.isHidden = false
      addPhotoImageView.isHidden = true
    }
  }
}

