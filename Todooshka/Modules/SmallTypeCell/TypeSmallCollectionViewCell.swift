//
//  TypeSmallCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 19.04.2022.
//


import UIKit
import Foundation

class TypeSmallCollectionViewCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "TypeSmallCollectionViewCell"
  
  let shapeLayer = CAShapeLayer()
  var oldShapeLayer: CAShapeLayer?
  
  //MARK: - UI Elements
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
    textView.font = UIFont.systemFont(ofSize: 10.superAdjusted, weight: .medium)
    textView.isUserInteractionEnabled = false
    return textView
  }()
  
  // draw
  override func draw(_ rect: CGRect) {

    // adding
    contentView.addSubview(imageView)
    contentView.addSubview(textView)
    
    // contentView
    contentView.cornerRadius = 11
    contentView.clipsToBounds = false
    contentView.layer.masksToBounds = false
    
    // taskTypeImageView
    imageView.anchorCenterXToSuperview()
    imageView.anchor(top: contentView.topAnchor, topConstant: 4, widthConstant: 25, heightConstant: 25)
    
    // taskTypeTextView
    textView.anchor(top: imageView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
    
    // shapeLayer
    shapeLayer.frame = bounds
    shapeLayer.lineWidth = 1
    shapeLayer.cornerRadius = 11
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
    
    if let oldShapeLayer = oldShapeLayer {
      contentView.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
    } else {
      contentView.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    oldShapeLayer = shapeLayer
  }
  
  // MARK: - Configure
  func configure(with kindOfTask: KindOfTask, isSelected: Bool, isEnabled: Bool) {

    // contentView
    contentView.borderWidth = isSelected ? 2.0 : 0.0
    contentView.borderColor = isSelected ? Palette.SingleColors.BlueRibbon : nil
    
    // textView
    textView.text = kindOfTask.text
    textView.textColor = Theme.App.text // isSelected ? Theme.TypeSmallCollectionViewCell.selectedText : Theme.App.text
    
    // taskTypeImageView
    imageView.image = kindOfTask.icon.image
    imageView.tintColor = kindOfTask.color
    
    // shapeLayer
    shapeLayer.fillColor = isEnabled ? (isSelected ? Theme.Bird.TypeSmallCollectionViewCell.unselectedBackground?.cgColor : Theme.Bird.TypeSmallCollectionViewCell.unselectedBackground?.cgColor) : Palette.SingleColors.SantasGray.withAlphaComponent(0.3).cgColor
  }
}



