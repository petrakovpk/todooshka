//
//  TaskTypeListCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.08.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class TaskTypeListCollectionViewCell: SwipeCollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "TaskTypeListCollectionViewCell"
  var viewModel: TaskTypeListCollectionViewCellModel!
  
  //MARK: UI Elements
  private let imageView = UIImageView()
  private let label = UILabel()
  
  //MARK: - Configure
  func configure(with type: TaskType) {
    
    contentView.cornerRadius = height / 2
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = UIColor(named: "taskTypeCellBorder")?.cgColor
    contentView.backgroundColor = UIColor(named: "taskTypeCellBackground")
    contentView.layer.masksToBounds = false
    
    imageView.image = type.image
    imageView.tintColor = type.imageColor
    imageView.contentMode = .scaleAspectFit

    contentView.addSubview(imageView)
    imageView.anchor(left: contentView.leftAnchor, leftConstant: 8, widthConstant: 40)
    imageView.anchorCenterYToSuperview()

    label.text = type.text
    label.textAlignment = .left

    contentView.addSubview(label)
    label.anchor(left: imageView.rightAnchor, right: contentView.rightAnchor, leftConstant: 8)
    label.anchorCenterYToSuperview()
  }
  
  func bindTo(viewModel: TaskTypeListCollectionViewCellModel) {
    self.viewModel = viewModel
    
    if let type = viewModel.type.value {
      configure(with: type)
    }
    
    delegate = viewModel
   
  }
}
