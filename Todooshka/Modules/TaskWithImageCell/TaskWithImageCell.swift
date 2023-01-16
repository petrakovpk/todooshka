//
//  TaskWithImageCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.01.2023.
//

import UIKit
import Foundation

class TaskWithImageCell: UICollectionViewCell {
  static var reuseID: String = "TaskWithImageCell"
  
  // MARK: - UI Properties
  private let kindOfTaskImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let taskTextLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.textAlignment = .center
    return label
  }()
  
  private let descriptionTextLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
    label.textColor = Style.Cells.TaskList.Description
    return label
  }()
  
  private let resultImageView: UIImageView = {
    let imageView = UIImageView()
    
    return imageView
  }()

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    cornerRadius = 15
    contentView.backgroundColor = .systemBlue.withAlphaComponent(0.3)

    contentView.addSubviews([
      kindOfTaskImageView,
      taskTextLabel,
      descriptionTextLabel,
      resultImageView
    ])
    
    // kindOfTaskImageView
    kindOfTaskImageView.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      topConstant: 16,
      leftConstant: 8,
      widthConstant: 20,
      heightConstant: 20)
    
    // taskTextLabel
    taskTextLabel.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      right: contentView.rightAnchor,
      topConstant: 16,
      leftConstant: 8,
      bottomConstant: 8,
      rightConstant: 8)
    
    // descriptionTextLabel
    descriptionTextLabel.anchor(
      top: taskTextLabel.bottomAnchor,
      left: contentView.leftAnchor,
      right: contentView.rightAnchor,
      topConstant: 16,
      leftConstant: 8,
      bottomConstant: 8,
      rightConstant: 8,
      heightConstant: 25)
    
    
  }

  // MARK: - UI Elements
  func configure(with task: Task) {
    
  }
}


