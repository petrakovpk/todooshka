//
//  TypeLargeCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.

import UIKit
import Foundation

class KindCell: UICollectionViewCell {
  static var reuseID: String = "KindCell"

  let shapeLayer = CAShapeLayer()
  var oldShapeLayer: CAShapeLayer?

  // MARK: - UI Elements
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = .white
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private let textView: UITextView = {
    let textView = UITextView()
    textView.textAlignment = .center
    textView.backgroundColor = .clear
    textView.textContainer.lineBreakMode = .byWordWrapping
    textView.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    textView.isUserInteractionEnabled = false
    return textView
  }()

  // draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    shapeLayer.frame = bounds
    shapeLayer.lineWidth = 1
    shapeLayer.cornerRadius = 11
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
    
    contentView.addSubviews([
      imageView,
      textView
    ])

    contentView.cornerRadius = 11
    contentView.clipsToBounds = false
    contentView.layer.masksToBounds = false

    imageView.anchorCenterXToSuperview()
    imageView.anchorCenterYToSuperview(constant: -1 * contentView.bounds.height / 6)

    textView.anchor(
      top: imageView.bottomAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor)

    if let oldShapeLayer = oldShapeLayer {
      contentView.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
    } else {
      contentView.layer.insertSublayer(shapeLayer, at: 0)
    }

    oldShapeLayer = shapeLayer
  }

  // MARK: - Configure
  func configure(with item: KindSectionItem) {
    let kind = item.kind
    let isSelected = item.isSelected
    
    textView.text = kind.text
    textView.textColor = isSelected ? .white : Style.App.text

    imageView.image = kind.icon?.image.template
    imageView.tintColor = isSelected ? .white : item.kind.color

    shapeLayer.borderWidth = isSelected ? 0 : 1
    shapeLayer.borderColor = Style.Cells.Kind.Border?.cgColor
    shapeLayer.shadowOpacity = isSelected ? 1 : 0
    shapeLayer.shadowRadius = isSelected ? 7 : 0
    shapeLayer.shadowPath = isSelected ? shapeLayer.path : nil
    shapeLayer.shadowOffset = isSelected ? CGSize(width: 0, height: 4) : CGSize(width: 0, height: 0)
    shapeLayer.shadowColor = isSelected ? Style.Cells.Kind.SelectedBackground.cgColor : UIColor.clear.cgColor
    shapeLayer.fillColor = isSelected ? Style.Cells.Kind.SelectedBackground.cgColor : Style.Cells.Kind.UnselectedBackground?.cgColor
  }
}
