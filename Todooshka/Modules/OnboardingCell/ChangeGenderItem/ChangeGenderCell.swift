//
//  ChangeGenderCell.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//


import UIKit

class ChangeGenderCell: UITableViewCell {
  
  // MARK: - Properties
  static var reuseID: String = "ChangeGenderCell"
  
  // MARK: - UI Elements
  private let isSelectedImageView: UIImageView = {
    let imageView = UIImageView()
    
    return imageView
  }()
  
  // MARK: - Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    // adding
    contentView.addSubview(isSelectedImageView)
    
    // contentView
    contentView.backgroundColor = Style.App.background
    
    // isSelectedImageView
    isSelectedImageView.anchorCenterYToSuperview()
    isSelectedImageView.anchor(right: contentView.rightAnchor, rightConstant: 16, widthConstant: 25, heightConstant: 25)

  }
  
  // MARK: - Configure
  func configure(text: String, isSelected: Bool ) {
    textLabel?.text = text
    let selectedImage = UIImage(named: "selectedRound")?.withTintColor(Palette.SingleColors.BlueRibbon, renderingMode: .alwaysTemplate)
    isSelectedImageView.image = isSelected ? selectedImage : UIImage(named: "round")
  }
}

