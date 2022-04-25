//
//  TaskTypeIconCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import UIKit
import RxSwift
import RxCocoa

class TaskTypeIconCollectionViewCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "TaskTypeIconCollectionViewCell"
  var viewModel: TaskTypeIconCollectionViewCellModel!
  var disposeBag = DisposeBag()
  
  //MARK: - UI Elements
  private let imageView = UIImageView()
  
  let shapeLayer = CAShapeLayer()
  var oldShapeLayer: CAShapeLayer?
  
  //MARK: - Draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    bindViewModel()
    
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

  //MARK: - Bind to ViewModel
  func bindViewModel() {
    let outputs = viewModel.transform()
    
    [
      outputs.isSelected.drive(isSelectedBinder),
      outputs.image.drive(imageView.rx.image)
    ]
      .forEach({$0.disposed(by: disposeBag)})
  }
  
  var isSelectedBinder: Binder<Bool> {
    return Binder(self, binding: { (cell, isSelected) in
      cell.shapeLayer.fillColor =   isSelected ? UIColor.Palette.BlueRibbon?.cgColor : Theme.Cell.background?.cgColor
      cell.shapeLayer.strokeColor = isSelected ? nil : Theme.Cell.border?.cgColor
      cell.shapeLayer.shadowColor = isSelected ? UIColor.Palette.BlueRibbon?.cgColor : UIColor.clear.cgColor
      cell.imageView.tintColor =    isSelected ? UIColor.white : Theme.App.text
    })
  }
}

