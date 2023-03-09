//
//  FunSectionCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import UIKit

class FunSectionCell: UITableViewCell {
  static var reuseID: String = "FunSectionCell"
  
  private let authorImageView: UIImageView = {
    let view = UIImageView()
    view.backgroundColor = .black.withAlphaComponent(0.2)
    view.cornerRadius = 5
    return view
  }()
  
  private let authorNameLabel: UILabel = {
    let label = UILabel()
    label.text = "Eric Coolguard"
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    return label
  }()
  
  private let customTextLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 2
    label.text = "Помыть машину"
    return label
  }()
  
  private let customImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 5
    imageView.backgroundColor = .black.withAlphaComponent(0.2)
    return imageView
  }()
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    backgroundColor = Style.App.background
    
    contentView.addSubviews([
      authorImageView,
      authorNameLabel,
      customTextLabel,
      customImageView
    ])
    
    authorImageView.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 50,
      heightConstant: 50
    )
    
    authorNameLabel.anchor(
      top: contentView.topAnchor,
      left: authorImageView.rightAnchor,
      right: contentView.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16
    )
    
    customTextLabel.anchor(
      top: authorNameLabel.bottomAnchor,
      left: authorImageView.rightAnchor,
      right: contentView.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    customImageView.anchor(
      top: authorImageView.bottomAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
  }
  
  func configure(with item: FunSectionItem) {
    
  }
}

