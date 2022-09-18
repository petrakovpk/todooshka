//
//  TypeLargeCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.

import UIKit
import Foundation

class TypeLargeCollectionViewCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "TypeLargeCollectionViewCell"
  
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
    textView.font = UIFont.systemFont(ofSize: 13.superAdjusted, weight: .medium)
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
    imageView.anchorCenterYToSuperview(constant: -1 * contentView.bounds.height / 6)
    
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
  func configure(kindOfTask: KindOfTask, isSelected: Bool) {

    // textView
    textView.text = kindOfTask.text
    textView.textColor = isSelected ? Theme.Task.TypeLargeCollectionViewCell.selectedText : Theme.App.text
    
    // imageView
    imageView.image = kindOfTask.icon.image
    imageView.tintColor = isSelected ? .white : kindOfTask.color
    
    // shapeLayer
    shapeLayer.shadowOpacity = isSelected ? 1 : 0
    shapeLayer.shadowRadius = isSelected ? 7 : 0
    shapeLayer.shadowPath = isSelected ? shapeLayer.path : nil
    shapeLayer.shadowOffset = isSelected ? CGSize(width: 0, height: 4) : CGSize(width: 0, height: 0)
    shapeLayer.shadowColor = isSelected ? Theme.Task.TypeLargeCollectionViewCell.selectedBackground.cgColor : UIColor.clear.cgColor
    shapeLayer.fillColor = isSelected ? Theme.Task.TypeLargeCollectionViewCell.selectedBackground.cgColor : Theme.Task.TypeLargeCollectionViewCell.unselectedBackground?.cgColor
  }
}


