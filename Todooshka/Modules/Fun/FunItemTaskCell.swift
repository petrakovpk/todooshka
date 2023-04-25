//
//  FunSectionCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import Lottie
import SkeletonView
import UIKit

class FunItemTaskCell: UITableViewCell {
  static var reuseID: String = "FunItemTaskCell"
  
  // MARK: - UI Elements
  private let authorImageView: UIImageView = {
    let view = UIImageView()
    view.cornerRadius = 5
    view.isSkeletonable = true
    view.contentMode = .scaleAspectFit
    return view
  }()
  
  private let authorNameLabel: UILabel = {
    let label = UILabel()
    label.cornerRadius = 5
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.isSkeletonable = true
    return label
  }()
  
  public let taskTextLabel: UILabel = {
    let label = UILabel()
    label.cornerRadius = 5
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 2
    label.isSkeletonable = true
    return label
  }()
  
  private let resultImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 5
    imageView.isSkeletonable = true
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private var skeletonTrigger: Bool = false
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

  
  
  private func setupUI() {
    backgroundColor = Style.App.background
    selectionStyle = .none
    contentView.addSubviews([
      authorImageView,
      authorNameLabel,
      taskTextLabel,
      resultImageView
    ])
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    authorImageView.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      topConstant: 16,
      widthConstant: 75,
      heightConstant: 75
    )
    
    authorNameLabel.anchor(
      top: contentView.topAnchor,
      left: authorImageView.rightAnchor,
      right: contentView.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      heightConstant: 20
    )
    
    taskTextLabel.anchor(
      top: authorNameLabel.bottomAnchor,
      left: authorImageView.rightAnchor,
      right: contentView.rightAnchor,
      topConstant: 5,
      leftConstant: 16,
      heightConstant: 50
    )
    
    resultImageView.anchor(
      top: taskTextLabel.bottomAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor,
      topConstant: 16
    )
  }
  
  func configure(with item: FunItemTask) {
    if item.isLoading {
      authorImageView.showSkeleton(usingColor: .lightGray.withAlphaComponent(0.5))
      authorNameLabel.showSkeleton(usingColor: .lightGray.withAlphaComponent(0.5))
      taskTextLabel.showSkeleton(usingColor: .lightGray.withAlphaComponent(0.5))
      resultImageView.showSkeleton(usingColor: .lightGray.withAlphaComponent(0.5))
    } else {
      authorImageView.hideSkeleton()
      authorNameLabel.hideSkeleton()
      taskTextLabel.hideSkeleton()
      resultImageView.hideSkeleton()
      taskTextLabel.text = item.task.text
      resultImageView.image = item.image
    }
    
  }
}
