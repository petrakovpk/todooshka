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
  public var isSelected: Bool = false {
    didSet {
      configureIsSelected(isSelected: isSelected)
    }
  }
  
  // MARK: - UI Properties
  private let offerBackgroundView: UIView = {
    let view = UIView()
    view.cornerRadius = 15
    view.backgroundColor = Theme.Diamond.OfferCell.notSeleted.offerBackground
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
    backgroundColor = Theme.GameCurrency.textViewBackground
    
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
    case .Small:
      offerNameLabel.text = "Компактный"
      offerScoreLabel.text = "5  шт."
      priceLabel.text = "99 руб."
      diamondImageView.anchorCenterYToSuperview()
      diamondImageView.anchorCenterXToSuperview()
      diamondImageView.anchor(widthConstant: viewWidth / 6)
    case .Medium:
      offerNameLabel.text = "Оптимальный"
      offerScoreLabel.text = "15 шт."
      priceLabel.text = "149 руб."
      diamondImageView.anchorCenterYToSuperview()
      diamondImageView.anchorCenterXToSuperview()
      diamondImageView.anchor(widthConstant: viewWidth / 5)
    case .Large:
      offerNameLabel.text = "Luxury"
      offerScoreLabel.text = "25 шт."
      priceLabel.text = "249 руб."
      diamondImageView.anchorCenterYToSuperview()
      diamondImageView.anchorCenterXToSuperview()
      diamondImageView.anchor(widthConstant: viewWidth / 4)
    }
  }
  
  func configureIsSelected(isSelected: Bool) {
    backgroundColor = isSelected ? Theme.Diamond.OfferCell.selected.background : Theme.Diamond.OfferCell.notSeleted.background
    offerBackgroundView.backgroundColor = isSelected ? Theme.Diamond.OfferCell.selected.offerBackground : Theme.Diamond.OfferCell.notSeleted.offerBackground
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
