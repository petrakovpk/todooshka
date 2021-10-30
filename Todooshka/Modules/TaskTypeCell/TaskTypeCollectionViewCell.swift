//
//  TaskTypeCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.

import UIKit
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class TaskTypeCollectionViewCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "TaskTypeCollectionViewCell"
  var viewModel: TaskTypeCollectionViewCellModel!
  var disposeBag = DisposeBag()
  
  let shapeLayer = CAShapeLayer()
  var oldShapeLayer: CAShapeLayer?
  
  override func draw(_ rect: CGRect) {
    bindViewModel()
    
    contentView.cornerRadius = 11
    contentView.clipsToBounds = false
    
    contentView.addSubview(taskTypeImageView)
    taskTypeImageView.anchorCenterXToSuperview()
    taskTypeImageView.anchorCenterYToSuperview(constant: -1 * contentView.bounds.height / 6)
    
    contentView.addSubview(taskTypeTextView)
    taskTypeTextView.anchor(top: taskTypeImageView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
    
    shapeLayer.frame = bounds
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
    
    shapeLayer.lineWidth = 1
    shapeLayer.shadowPath = shapeLayer.path
    shapeLayer.shadowOpacity = 1
    shapeLayer.shadowRadius = 18
    shapeLayer.shadowOffset = CGSize(width: 0, height: 4)
    shapeLayer.cornerRadius = 11
    
    if let oldShapeLayer = oldShapeLayer {
      contentView.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
    } else {
      contentView.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    oldShapeLayer = shapeLayer
  }
  
  //MARK: - UI Elements
  private let taskTypeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = .white
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let taskTypeTextView: UITextView = {
    let textView = UITextView()
    textView.textAlignment = .center
    textView.backgroundColor = .clear
    textView.textContainer.lineBreakMode = .byWordWrapping
    textView.font = UIFont.systemFont(ofSize: 13.superAdjusted, weight: .medium)
    textView.isUserInteractionEnabled = false
    return textView
  }()
  
  private var imageColor: UIColor?
  
  //MARK: - Bind
  func bindViewModel() {
    let output = viewModel.transform()
    output.typeImageColor.drive { self.imageColor = $0 }.disposed(by: disposeBag)
    output.typeImage.drive(taskTypeImageView.rx.image).disposed(by: disposeBag)
    output.typeText.drive(taskTypeTextView.rx.text).disposed(by: disposeBag)
    output.isSelected.drive(isSelectedBinder).disposed(by: disposeBag)
  }
  
  var isSelectedBinder: Binder<Bool> {
    return Binder(self, binding: { (cell, isSelected) in
      cell.shapeLayer.fillColor        = isSelected ? UIColor.blueRibbon.cgColor  : UIColor(named: "taskTypeCellBackground")?.cgColor
      cell.shapeLayer.strokeColor      = isSelected ? nil                         : UIColor(named: "taskTypeCellBorder")?.cgColor
      cell.shapeLayer.shadowColor      = isSelected ? UIColor.blueRibbon.cgColor  : UIColor.clear.cgColor
      cell.taskTypeImageView.tintColor = isSelected ? UIColor.white               : cell.imageColor
      cell.taskTypeTextView.textColor  = isSelected ? UIColor.white               : UIColor(named: "appText")
    })
  }
    
  
}


