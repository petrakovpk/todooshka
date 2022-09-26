//
//  KindOfTaskColorCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 15.09.2021.
//

import UIKit
import RxSwift
import RxCocoa

class KindOfTaskColorCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "KindOfTaskColorCell"
  
  private let radius: CGFloat = 20
  
  private let iconImageView = UIImageView()
  private let icon = UIImage(named: "tick")?.template
  
  private let shapeLayer = CAShapeLayer()
  private var oldShapeLayer: CAShapeLayer?
  
  
  //MARK: - Draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    configureUI()
  }
  
  func configureUI() {
    // adding
    contentView.addSubview(iconImageView)
    
    // contentView
    contentView.cornerRadius = contentView.bounds.height / 2
    
    // iconImageView
    iconImageView.image = icon
    iconImageView.tintColor = Theme.App.background
    iconImageView.anchorCenterXToSuperview()
    iconImageView.anchorCenterYToSuperview()
    
    // shapeLayer
    shapeLayer.lineWidth = 4.0
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = Theme.App.background!.cgColor
    shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).cgPath
    shapeLayer.position = CGPoint(x: contentView.center.x - radius, y: contentView.center.y - radius)

    if let oldShapeLayer = oldShapeLayer {
      contentView.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
    } else {
      contentView.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    oldShapeLayer = shapeLayer
  }
  
  func configure(with item: KindOfTaskColorItem) {
    iconImageView.isHidden = !item.isSelected
    shapeLayer.isHidden = !item.isSelected
    UIView.performWithoutAnimation {
      contentView.backgroundColor = item.color
    }
  }
  
  //MARK: - Bind to ViewModel
//  func bindViewModel() {
//    let output = viewModel.transform()
//    output.color.drive(contentView.rx.backgroundColor).disposed(by: disposeBag)
//    output.isSelected.drive(isSelectedBinder).disposed(by: disposeBag)
//  }
  
//  var isSelectedBinder: Binder<Bool> {
//    return Binder(self, binding: { (cell, isSelected) in
//      cell.iconImageView.isHidden = !isSelected
//      cell.shapeLayer.isHidden = !isSelected
//    })
//  }
}
