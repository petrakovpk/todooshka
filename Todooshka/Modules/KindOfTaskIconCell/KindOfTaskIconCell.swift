//
//  KindOfTaskIconCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import UIKit
import RxSwift
import RxCocoa

class KindOfTaskIconCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "KindOfTaskIconCell"
  
  //MARK: - UI Elements
  private let imageView = UIImageView()
  
  let shapeLayer = CAShapeLayer()
  var oldShapeLayer: CAShapeLayer?
  
  //MARK: - Draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    contentView.addSubview(imageView)
    imageView.anchorCenterXToSuperview()
    imageView.anchorCenterYToSuperview()
    
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
    shapeLayer.lineWidth = 1
    shapeLayer.shadowPath = shapeLayer.path
    shapeLayer.shadowOpacity = 1
    shapeLayer.shadowRadius = 18
    shapeLayer.shadowOffset = CGSize(width: 0, height: 4)
    
    if let oldShapeLayer = oldShapeLayer {
      contentView.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
    } else {
      contentView.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    oldShapeLayer = shapeLayer
  }

  func configure(with item: KindOfTaskIconItem) {
    UIView.performWithoutAnimation {
      imageView.image = item.icon.image
    }
    
    shapeLayer.fillColor =   item.isSelected ? Palette.SingleColors.BlueRibbon.cgColor : Theme.TaskType.Cell.background?.cgColor
    shapeLayer.strokeColor = item.isSelected ? nil : Theme.TaskType.Cell.border?.cgColor
    shapeLayer.shadowColor = item.isSelected ? Palette.SingleColors.BlueRibbon.cgColor : UIColor.clear.cgColor
    imageView.tintColor =    item.isSelected ? UIColor.white : Theme.App.text
    
  }
  
  // MARK: - Bind to ViewModel
//  func bindViewModel() {
//    let outputs = viewModel.transform()
//
//    [
//      outputs.isSelected.drive(isSelectedBinder),
//      outputs.image.drive(imageView.rx.image)
//    ]
//      .forEach({$0.disposed(by: disposeBag)})
//  }
//
//  var isSelectedBinder: Binder<Bool> {
//    return Binder(self, binding: { (cell, isSelected) in
//      cell.shapeLayer.fillColor =   isSelected ? Palette.SingleColors.BlueRibbon.cgColor : Theme.TaskType.Cell.background?.cgColor
//      cell.shapeLayer.strokeColor = isSelected ? nil : Theme.TaskType.Cell.border?.cgColor
//      cell.shapeLayer.shadowColor = isSelected ? Palette.SingleColors.BlueRibbon.cgColor : UIColor.clear.cgColor
//      cell.imageView.tintColor =    isSelected ? UIColor.white : Theme.App.text
//    })
//  }
}

