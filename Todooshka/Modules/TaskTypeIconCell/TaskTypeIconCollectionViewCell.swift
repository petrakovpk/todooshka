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
    let output = viewModel.transform()
    output.isSelected.drive(isSelectedBinder).disposed(by: disposeBag)
    output.icon.drive(imageView.rx.image).disposed(by: disposeBag)
  }
  
  var isSelectedBinder: Binder<Bool> {
    return Binder(self, binding: { (cell, isSelected) in
      cell.shapeLayer.fillColor =   isSelected ? UIColor.blueRibbon.cgColor  : UIColor(named: "taskTypeCellBackground")?.cgColor
      cell.shapeLayer.strokeColor = isSelected ? nil                         : UIColor(named: "taskTypeCellBorder")?.cgColor
      cell.shapeLayer.shadowColor = isSelected ? UIColor.blueRibbon.cgColor  : UIColor.clear.cgColor
      cell.imageView.tintColor =    isSelected ? UIColor.white               : UIColor(named: "appText")
    })
  }
}

