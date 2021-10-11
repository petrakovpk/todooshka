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
    shapeLayer.frame = bounds
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
    
    shapeLayer.lineWidth = 1
    shapeLayer.shadowPath = shapeLayer.path
    shapeLayer.shadowOpacity = 1
    shapeLayer.shadowRadius = 18
    shapeLayer.shadowOffset = CGSize(width: 0, height: 4)
    
    if viewModel.isSelected.value ?? false {
      shapeLayer.fillColor = UIColor.blueRibbon.cgColor
      shapeLayer.strokeColor = UIColor(named: "taskTypeCellBorder")?.cgColor
      shapeLayer.shadowColor = UIColor.blueRibbon.cgColor
    } else {
      shapeLayer.fillColor = UIColor(named: "taskTypeCellBackground")?.cgColor
      shapeLayer.strokeColor = UIColor(named: "taskTypeCellBorder")?.cgColor
      shapeLayer.shadowColor = UIColor.clear.cgColor
    }
   
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
    textView.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    textView.isUserInteractionEnabled = false
    return textView
  }()
  
  private var imageColor: UIColor?
  
  //MARK: - Bind
  func bindToViewModel(viewModel: TaskTypeCollectionViewCellModel){
    self.viewModel = viewModel
    
    contentView.cornerRadius = 11
    contentView.clipsToBounds = false
    
    contentView.addSubview(taskTypeImageView)
    taskTypeImageView.anchorCenterXToSuperview()
    taskTypeImageView.anchorCenterYToSuperview(constant: -1 * contentView.bounds.height / 6)
    
    contentView.addSubview(taskTypeTextView)
    taskTypeTextView.anchor(top: taskTypeImageView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
    
    viewModel.type.bind{ [weak self] type in
      guard let self = self else { return }
      guard let type = type else { return }
      self.taskTypeImageView.image = type.image
      self.taskTypeImageView.tintColor = type.imageColor
      self.imageColor = type.imageColor
      self.taskTypeTextView.text = type.text
    }.disposed(by: disposeBag)
    
    viewModel.isSelected.bind{ [weak self] isSelected in
      guard let self = self else { return }
      guard let isSelected = isSelected else { return }
      if isSelected {
        self.shapeLayer.fillColor = UIColor.blueRibbon.cgColor
        self.shapeLayer.shadowColor = UIColor.blueRibbon.cgColor
        self.taskTypeTextView.textColor = .white
        self.taskTypeImageView.tintColor = .white
      } else {
        self.shapeLayer.fillColor = UIColor(named: "taskTypeCellBackground")?.cgColor
        self.shapeLayer.shadowColor = UIColor.clear.cgColor
        self.taskTypeTextView.textColor = UIColor(named: "appText")
        self.taskTypeImageView.tintColor = self.imageColor
      }
      self.layoutIfNeeded()
    }.disposed(by: disposeBag)
  }
  
  
}


