//
//  AlertBuyView.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.05.2022.
//

import UIKit


class AlertBuyView: UIView {
  
  // MARK: - Public UI Properties
  public let eggImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  public let birdImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  public let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    return label
  }()
  
  public let cancelButton: UIButton = {
    let button = UIButton(type: .system)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Theme.App.text?.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  public let buyButton: AlertBuyButton = {
    let button = AlertBuyButton(type: .system)
    let attrString = NSAttributedString(string: "Купить!", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.layer.cornerRadius = 15
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  // MARK: - Private UI Properties
  private let windowView: UIView = {
    let view = UIView()
    view.backgroundColor = Theme.App.background
    return view
  }()
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    
    // adding
    addSubview(windowView)
    
    windowView.addSubviews([
      eggImageView,
      birdImageView,
      label,
      cancelButton,
      buyButton
    ])
    
    backgroundColor = Theme.Views.Alert.Background
    
    // alertBackgroundView
    windowView.layer.cornerRadius = 15
    windowView.anchorCenterXToSuperview()
    windowView.anchorCenterYToSuperview()
    windowView.anchor(widthConstant: Sizes.Views.alertBuyBirdView.width, heightConstant: Sizes.Views.alertBuyBirdView.height)
    
    // eggImageView
    eggImageView.anchor(
      top: windowView.topAnchor,
      left: windowView.leftAnchor,
      topConstant: Sizes.ImageViews.alertEggImageView.TopConstant,
      leftConstant: Sizes.ImageViews.alertEggImageView.LeftConstant,
      widthConstant: Sizes.ImageViews.alertEggImageView.width,
      heightConstant: Sizes.ImageViews.alertEggImageView.height
    )

    // birdImageView
    birdImageView.anchor(
      top: windowView.topAnchor,
      right: windowView.rightAnchor,
      topConstant: Sizes.ImageViews.alertBirdImageView.TopConstant,
      rightConstant: Sizes.ImageViews.alertBirdImageView.RightConstant,
      widthConstant: Sizes.ImageViews.alertBirdImageView.width,
      heightConstant: Sizes.ImageViews.alertBirdImageView.height
    )
    
    // cancelButton
    cancelButton.anchor(
      left: windowView.leftAnchor,
      bottom: windowView.bottomAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      widthConstant: Sizes.Buttons.alertBuyBirdButton.width,
      heightConstant: Sizes.Buttons.alertBuyBirdButton.height
    )
    
    // buyButton
    buyButton.anchor(
      bottom: windowView.bottomAnchor,
      right: windowView.rightAnchor,
      bottomConstant: 16,
      rightConstant: 16,
      widthConstant: Sizes.Buttons.alertBuyBirdButton.width,
      heightConstant: Sizes.Buttons.alertBuyBirdButton.height
    )
    
    // label
    label.anchor(
      top: eggImageView.bottomAnchor,
      left: windowView.leftAnchor,
      bottom: cancelButton.topAnchor,
      right: windowView.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
