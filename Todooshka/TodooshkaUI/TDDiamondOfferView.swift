//
//  TDDiamondOfferView.swift
//  Todooshka
//
//  Created by Pavel Petakov on 19.07.2022.
//

import UIKit

class TDDiamondPackageOfferView: UIView {
  // MARK: - Const
  private let viewWidth = (UIScreen.main.bounds.width - 16 * 4) / 3
  
  // MARK: - Public properties
  public var isSelected = false {
    didSet {
      configureIsSelected(isSelected: isSelected)
    }
  }
  
  // MARK: - UI Properties
  private let offerBackgroundView: UIView = {
    let view = UIView()
    view.cornerRadius = 15
    view.backgroundColor = Style.Diamond.OfferCell.NotSeleted.offerBackground
    return view
  }()
  
  private let offerNameLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  private let offerScoreLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  private let diamondImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "diamond")
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let priceLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  // MARK: - Init
  init(type: DiamondPackageType) {
    super.init(frame: .zero)
    layer.cornerRadius = 15
    
    backgroundColor = Style.Views.GameCurrency.textViewBackground
    borderWidth = 1.0
    borderColor = Style.Cells.Kind.Border
    
    // adding
    addSubviews([offerBackgroundView, priceLabel])
    offerBackgroundView.addSubviews([offerNameLabel, diamondImageView, offerScoreLabel])
    
    // offerNameLabel
    offerNameLabel.anchor(top: offerBackgroundView.topAnchor, left: offerBackgroundView.leftAnchor, right: offerBackgroundView.rightAnchor, topConstant: 16, leftConstant: 8, rightConstant: 8)
    
    // offerScoreLabel
    offerScoreLabel.anchor(left: offerBackgroundView.leftAnchor, bottom: offerBackgroundView.bottomAnchor, right: offerBackgroundView.rightAnchor, leftConstant: 8, bottomConstant: 8, rightConstant: 8)
    
    // priceLabel
    priceLabel.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, bottomConstant: 8)
    
    // offerBackgroundView
    offerBackgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: priceLabel.topAnchor, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8)
    
    // type
    switch type {
    case .small:
      offerNameLabel.text = "Компактный"
      offerScoreLabel.text = "99  шт."
      priceLabel.text = "99 руб."
      diamondImageView.anchorCenterYToSuperview()
      diamondImageView.anchorCenterXToSuperview()
      diamondImageView.anchor(widthConstant: viewWidth / 6)
    case .medium:
      offerNameLabel.text = "Оптимальный"
      offerScoreLabel.text = "199 шт."
      priceLabel.text = "149 руб."
      diamondImageView.anchorCenterYToSuperview()
      diamondImageView.anchorCenterXToSuperview()
      diamondImageView.anchor(widthConstant: viewWidth / 5)
    case .large:
      offerNameLabel.text = "Самый выгодный"
      offerScoreLabel.text = "299 шт."
      priceLabel.text = "199 руб."
      diamondImageView.anchorCenterYToSuperview()
      diamondImageView.anchorCenterXToSuperview()
      diamondImageView.anchor(widthConstant: viewWidth / 4)
    }
  }
  
  func configureIsSelected(isSelected: Bool) {
    backgroundColor = isSelected ? Style.Diamond.OfferCell.Selected.background : Style.Diamond.OfferCell.NotSeleted.background
    offerBackgroundView.backgroundColor = isSelected ? Style.Diamond.OfferCell.Selected.offerBackground : Style.Diamond.OfferCell.NotSeleted.offerBackground
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
