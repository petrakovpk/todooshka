//
//  FunSectionCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import Lottie
import UIKit
import SkeletonView

class FunCell: UITableViewCell {
  static var reuseID: String = "FunItemTaskCell"
  
  // MARK: - UI Elements
  private let publicationTextView: UITextView = {
    let textView = UITextView()
    textView.backgroundColor = .lightGray.withAlphaComponent(0.2)
    textView.cornerRadius = 15
    textView.isEditable = false
    textView.textAlignment = .center
    return textView
  }()
  
  private let publicationImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .lightGray.withAlphaComponent(0.2)
    imageView.cornerRadius = 8
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
      publicationTextView,
      publicationImageView
    ])
    
    publicationTextView.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      right: contentView.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )

    publicationImageView.anchor(
      top: publicationTextView.bottomAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      bottomConstant: 8,
      rightConstant: 16
    )
  }
  
  private func setupConstraints() {
//    authorImageView.anchor(
//      top: contentView.topAnchor,
//      left: contentView.leftAnchor,
//      topConstant: 16,
//      widthConstant: 75,
//      heightConstant: 75
//    )
//
//    authorNameLabel.anchor(
//      top: contentView.topAnchor,
//      left: authorImageView.rightAnchor,
//      right: contentView.rightAnchor,
//      topConstant: 16,
//      leftConstant: 16,
//      heightConstant: 20
//    )
    
//    taskTextLabel.anchor(
//      top: contentView.topAnchor,
//      left: contentView.leftAnchor,
//      right: contentView.rightAnchor,
//      topConstant: 5,
//      leftConstant: 16,
//      heightConstant: 50
//    )
//
//    resultImageView.anchor(
//      top: taskTextLabel.bottomAnchor,
//      left: contentView.leftAnchor,
//      bottom: contentView.bottomAnchor,
//      right: contentView.rightAnchor,
//      topConstant: 16
//    )
  }
  
  func configure(with item: FunItem) {
    if item.isLoading {
      publicationTextView.showSkeleton(usingColor: .lightGray.withAlphaComponent(0.5))
      publicationImageView.showSkeleton(usingColor: .lightGray.withAlphaComponent(0.5))

    } else {
      publicationTextView.hideSkeleton()
      publicationImageView.hideSkeleton()
      publicationTextView.text = item.publication.text
      publicationImageView.image = item.image
    }
    
  }
}
