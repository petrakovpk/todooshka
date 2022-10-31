//
//  KindOfTaskForBirdCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 19.04.2022.
//

import UIKit
import Foundation

class KindOfTaskForBirdCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "KindOfTaskForBirdCell"
  
  let shapeLayer = CAShapeLayer()
  var oldShapeLayer: CAShapeLayer?
  var isPlusButton: Bool = false
  
  //MARK: - UI Elements
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = .white
    imageView.contentMode = .center
    return imageView
  }()
  
  private let textView: UITextView = {
    let textView = UITextView()
    textView.textAlignment = .center
    textView.backgroundColor = .clear
    textView.textContainer.lineBreakMode = .byWordWrapping
    textView.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    textView.isUserInteractionEnabled = false
    return textView
  }()
  
  // draw
  override func draw(_ rect: CGRect) {

    // contentView
    contentView.cornerRadius = 11
    contentView.clipsToBounds = false
    contentView.layer.masksToBounds = false

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
  func configureAsPlusButton() {
    // removeFromSuperview
    imageView.removeFromSuperview()
    textView.removeFromSuperview()
    
    // adding
    contentView.addSubview(imageView)
    
    // contentView
    contentView.backgroundColor = .clear
    contentView.borderWidth = 1.0
    contentView.borderColor = Style.App.text

    // imageView
    imageView.anchorCenterYToSuperview()
    imageView.anchorCenterXToSuperview()
    imageView.image = UIImage(named: "plus")?.template
    imageView.tintColor = Style.App.text
    
    // shapeLayer
    shapeLayer.fillColor = nil
  }
  
  func configure(with kindOfTask: KindOfTask, isEnabled: Bool) {
    // removeFromSuperview
    imageView.removeFromSuperview()
    textView.removeFromSuperview()
    
    // adding
    contentView.addSubview(imageView)
    contentView.addSubview(textView)
    
    // contentView
    contentView.borderWidth = 1.0
    contentView.borderColor = Style.Cells.KindOfTask.Border
    
    // shapeLayer
    shapeLayer.fillColor = isEnabled ? Style.Cells.KindOfTask.UnselectedBackground?.cgColor : UIColor.systemGray.withAlphaComponent(0.3).cgColor
    
    // imageView
    imageView.anchorCenterXToSuperview()
    imageView.anchor(top: contentView.topAnchor, topConstant: 12, widthConstant: 25, heightConstant: 25)
    imageView.image = kindOfTask.icon.image
    imageView.tintColor = kindOfTask.color

    // textView
    textView.anchor(top: imageView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
    textView.text = kindOfTask.text
    textView.textColor = Style.App.text
    
  }
}



