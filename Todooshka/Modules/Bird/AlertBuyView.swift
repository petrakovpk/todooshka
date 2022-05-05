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
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.adjusted, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Theme.App.text?.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  public let buyButton: AlertBuyButton = {
    let button = AlertBuyButton(type: .system)
    let attrString = NSAttributedString(string: "Купить!", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.adjusted, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.layer.cornerRadius = 15
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  // MARK: - Private UI Properties
  private let backgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = Theme.BuyAlertView.background
    return view
  }()
  
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = Theme.App.background
    return view
  }()
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    
    // adding
    addSubview(backgroundView)
    addSubview(alertBackgroundView)
    addSubview(eggImageView)
    addSubview(birdImageView)
    addSubview(label)
    addSubview(cancelButton)
    addSubview(buyButton)
    
    // backgroundView
    backgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    
    // alertBackgroundView
    alertBackgroundView.layer.cornerRadius = 15
    alertBackgroundView.anchorCenterXToSuperview()
    alertBackgroundView.anchorCenterYToSuperview()
    alertBackgroundView.anchor(widthConstant: Theme.BuyAlertView.width, heightConstant: Theme.BuyAlertView.height)
    
    // eggImageView
    eggImageView.anchor(top: alertBackgroundView.topAnchor, left: alertBackgroundView.leftAnchor, topConstant: Theme.BuyAlertView.eggImageView.topConstant, leftConstant: Theme.BuyAlertView.eggImageView.leftConstant, widthConstant: Theme.BuyAlertView.eggImageView.width, heightConstant: Theme.BuyAlertView.eggImageView.height)
    
    // birdImageView
    birdImageView.anchor(top: alertBackgroundView.topAnchor, right: alertBackgroundView.rightAnchor, topConstant: Theme.BuyAlertView.birdImageView.topConstant, rightConstant: Theme.BuyAlertView.birdImageView.rightConstant, widthConstant: Theme.BuyAlertView.birdImageView.width, heightConstant: Theme.BuyAlertView.birdImageView.height)
    
    // cancelButton
    cancelButton.anchor(left: alertBackgroundView.leftAnchor, bottom: alertBackgroundView.bottomAnchor, leftConstant: 16, bottomConstant: 16, widthConstant: Theme.BuyAlertView.cancelButton.width, heightConstant: 50)
    
    // buyButton
    buyButton.anchor(bottom: alertBackgroundView.bottomAnchor, right: alertBackgroundView.rightAnchor, bottomConstant: 16, rightConstant: 16, widthConstant: Theme.BuyAlertView.buyButton.width, heightConstant: 50)
    
    // label
    label.anchor(top: eggImageView.bottomAnchor, left: alertBackgroundView.leftAnchor, bottom: cancelButton.topAnchor, right: alertBackgroundView.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
