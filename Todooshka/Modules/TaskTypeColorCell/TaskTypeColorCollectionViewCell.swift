//
//  TaskTypeColorCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 15.09.2021.
//

import UIKit
import RxSwift
import RxCocoa

class TaskTypeColorCollectionViewCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "TaskTypeColorCollectionViewCell"
  var viewModel: TaskTypeColorCollectionViewCellModel!
  var disposeBag = DisposeBag()
  
  let iconImageView = UIImageView()
  let icon = UIImage(named: "tick")?.template
  
  let shapeLayer = CAShapeLayer()
  var oldShapeLayer: CAShapeLayer?
  
  //MARK: - Draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    bindViewModel()
    
    contentView.cornerRadius = contentView.bounds.height / 2
    
    iconImageView.image = icon
    iconImageView.tintColor = UIColor(named: "appBackground")
    
    contentView.addSubview(iconImageView)
    iconImageView.anchorCenterXToSuperview()
    iconImageView.anchorCenterYToSuperview()
    
    let radius: CGFloat = 20
    shapeLayer.lineWidth = 4.0
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = UIColor(named: "appBackground")!.cgColor
    shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).cgPath
    shapeLayer.position = CGPoint(x: contentView.center.x - radius, y: contentView.center.y - radius)

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
    output.color.drive(contentView.rx.backgroundColor).disposed(by: disposeBag)
    output.isSelected.drive(isSelectedBinder).disposed(by: disposeBag)
  }
  
  var isSelectedBinder: Binder<Bool> {
    return Binder(self, binding: { (cell, isSelected) in
      cell.iconImageView.isHidden = !isSelected
      cell.shapeLayer.isHidden = !isSelected
    })
  }
}
