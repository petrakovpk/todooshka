//
//  TaskTypeCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.

import UIKit
import RxSwift
import RxCocoa
import Foundation

class TaskTypeCollectionViewCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "TaskTypeCollectionViewCell"
  var viewModel: TaskTypeCollectionViewCellModel!
  var disposeBag = DisposeBag()
  
  let shapeLayer = CAShapeLayer()
  var oldShapeLayer: CAShapeLayer?
  
  override func draw(_ rect: CGRect) {
    if traitCollection.userInterfaceStyle == .dark {
      drawDarkMode()
    } else {
      drawLightMode()
    }
  }
  
  func drawLightMode() {
    shapeLayer.frame = bounds
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
    
    shapeLayer.lineWidth = 1
    shapeLayer.shadowPath = shapeLayer.path
    shapeLayer.shadowOpacity = 1
    shapeLayer.shadowRadius = 18
    shapeLayer.shadowOffset = CGSize(width: 0, height: 4)
    shapeLayer.shadowColor = UIColor.clear.cgColor
    
    if let oldShapeLayer = oldShapeLayer {
      contentView.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
    } else {
      contentView.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    oldShapeLayer = shapeLayer
  }
  
  func drawDarkMode() {
    shapeLayer.frame = bounds
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath
    
    shapeLayer.lineWidth = 1
    shapeLayer.shadowPath = shapeLayer.path
    shapeLayer.shadowOpacity = 1
    shapeLayer.shadowRadius = 18
    shapeLayer.shadowOffset = CGSize(width: 0, height: 4)
    shapeLayer.shadowColor = UIColor.clear.cgColor
    
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
  
  private let taskTypeTitle: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.tintColor = .white
    label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    return label
  }()
  
  private var imageColor: UIColor?
  
  //MARK: - Bind
  func bindToViewModel(viewModel: TaskTypeCollectionViewCellModel){
    self.viewModel = viewModel
    
    contentView.cornerRadius = 11
    contentView.clipsToBounds = false
    
    let stackView = UIStackView(arrangedSubviews: [taskTypeImageView,taskTypeTitle])
    stackView.axis = .vertical
    stackView.spacing = 8
    
    contentView.addSubview(stackView)
    stackView.anchorCenterXToSuperview()
    stackView.anchorCenterYToSuperview()
    
    viewModel.type.bind{ [weak self] type in
      guard let self = self else { return }
      guard let type = type else { return }
      self.taskTypeImageView.image = type.image
      self.taskTypeImageView.tintColor = type.imageColor
      self.imageColor = type.imageColor
      self.taskTypeTitle.text = type.text
    }.disposed(by: disposeBag)
    
    viewModel.isSelected.bind{ [weak self] isSelected in
      guard let self = self else { return }
      guard let isSelected = isSelected else { return }
      if isSelected {
        self.shapeLayer.fillColor = UIColor.blueRibbon.cgColor
        self.shapeLayer.shadowColor = UIColor.blueRibbon.cgColor
        self.taskTypeTitle.textColor = .white
        self.taskTypeImageView.tintColor = .white
      } else {
        self.shapeLayer.fillColor = UIColor(named: "typeCellBackgroundColor")?.cgColor
        self.shapeLayer.shadowColor = UIColor.clear.cgColor
        self.taskTypeTitle.textColor = UIColor(named: "appText")
        self.taskTypeImageView.tintColor = self.imageColor
      }
      self.layoutIfNeeded()
    }.disposed(by: disposeBag)
  }
}


