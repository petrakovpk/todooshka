//
//  ShopCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import UIKit

class ShopCollectionViewCell: UICollectionViewCell {
  
  // MARK: - Properties
  static var reuseID: String = "ShopCollectionViewCell"
  
  // MARK: - UI elements
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    return label
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.layer.cornerRadius = 15
    return imageView
  }()
  
  // MARK: - draw
  override func draw(_ rect: CGRect) {
    
    // contentView
    contentView.cornerRadius = 11
    contentView.backgroundColor = .systemGray.withAlphaComponent(0.3)
    
    // adding
    contentView.addSubview(nameLabel)
    contentView.addSubview(imageView)

    // nameLabel
    nameLabel.anchorCenterXToSuperview()
    nameLabel.anchor(bottom: contentView.bottomAnchor, bottomConstant: 8)
    
    // imageView
    imageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nameLabel.topAnchor, right: contentView.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
  }
  
  // MARK: - Configure UI
  func configure(bird: Bird) {
    nameLabel.text = bird.style.rawValue
    imageView.image = bird.image
  }
}
