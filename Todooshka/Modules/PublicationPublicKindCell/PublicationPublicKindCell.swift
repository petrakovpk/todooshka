//
//  PublicationPublicKindCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 19.05.2023.
//

import UIKit

class PublicationPublicKindCell: UICollectionViewCell {
  static var reuseID: String = "PublicationPublicKindCell"
  
  private let shapeLayer = CAShapeLayer()
  private var oldShapeLayer: CAShapeLayer?
  
  private var publicKindImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.cornerRadius = 11
    return imageView
  }()
  
  private var labelContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.layer.cornerRadius = 11
    view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    return view
  }()
  
  private var textLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .light)
    label.numberOfLines = 2
    label.lineBreakMode = .byWordWrapping
    return label
  }()
  
  override func draw(_ rect: CGRect) {
    shapeLayer.frame = bounds
    shapeLayer.lineWidth = 1
    shapeLayer.cornerRadius = 11
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
        
    contentView.cornerRadius = 11
    contentView.layer.masksToBounds = false
    
    contentView.addSubviews([
      publicKindImageView,
      labelContainerView
    ])
    
    labelContainerView.addSubviews([
      textLabel
    ])
    
    publicKindImageView.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor
    )

    labelContainerView.anchor(
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor,
      heightConstant: 30
    )
    
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    textLabel.anchorCenterYToSuperview()
    
    textLabel.anchor(
      left: labelContainerView.leftAnchor,
      right: labelContainerView.rightAnchor,
      leftConstant: 4,
      rightConstant: 4
    )
    
    if let oldShapeLayer = oldShapeLayer {
      contentView.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
    } else {
      contentView.layer.insertSublayer(shapeLayer, at: 0)
    }

    oldShapeLayer = shapeLayer
  }
  
  func configure(with item: PublicKindItem) {
    switch item.publicKindItemType {
    case .empty:
      publicKindImageView.image = nil
      textLabel.text = "Без категории"
    case .kind(let kind):
      publicKindImageView.image = kind.image
      textLabel.text = kind.text
    }
    
    if item.isSelected {
      labelContainerView.backgroundColor = Style.Cells.Kind.SelectedBackground
      textLabel.textColor = .white
      shapeLayer.shadowOpacity = 1
      shapeLayer.shadowRadius = 7
      shapeLayer.shadowPath = shapeLayer.path
      shapeLayer.shadowOffset = CGSize(width: 0, height: 4)
      shapeLayer.shadowColor = Style.Cells.Kind.SelectedBackground.cgColor
      shapeLayer.fillColor = Style.Cells.Kind.SelectedBackground.cgColor
    } else {
      labelContainerView.backgroundColor = Style.Cells.Kind.UnselectedBackground
      textLabel.textColor = Style.App.text
      shapeLayer.shadowOpacity = 0
      shapeLayer.shadowRadius = 0
      shapeLayer.shadowPath = nil
      shapeLayer.shadowOffset = CGSize(width: 0, height: 0)
      shapeLayer.shadowColor = UIColor.clear.cgColor
      shapeLayer.fillColor = Style.Cells.Kind.UnselectedBackground?.cgColor
    }
  }
}
