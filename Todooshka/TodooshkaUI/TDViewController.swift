//
//  TDViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 30.09.2021.
//

import UIKit

class TDViewController: UIViewController {
  // MARK: - UI Elements
  public let titleLabel = UILabel()
  public let headerView = UIView()

  public let backButton: UIButton = {
    let button = UIButton(type: .system)
    button.isHidden = true
    button.setImage(Icon.arrowLeft.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()

  public let addButton: UIButton = {
    let button = UIButton(type: .system)
    button.isHidden = true
    button.setImage(Icon.addSquare.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()
  
  public let refreshButton: UIButton = {
    let button = UIButton(type: .system)
    button.isHidden = true
    button.setImage(Icon.rotateRight.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()

  public let removeAllButton: UIButton = {
    let button = UIButton(type: .system)
    button.isHidden = true
    button.setImage(Icon.trashCustom.image, for: .normal)
    return button
  }()
  
  public let saveButton: UIButton = {
    let button = UIButton(type: .system)
    button.isHidden = true
    button.setImage(Icon.tickSquare.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()

  public let settingsButton: UIButton = {
    let button = UIButton(type: .system)
    button.isHidden = true
    button.setImage(Icon.settingsGear.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()
  
  private let safeAreaHeaderView = UIView()
  private let dividerView = UIView()

  // MARK: - Lifecycle
  open override func viewDidLoad() {
    super.viewDidLoad()
    configureHeader()
  }

  // MARK: - Configure
  private func configureHeader() {
    // adding
    view.addSubviews([
      safeAreaHeaderView,
      headerView
    ])

    // view
    view.backgroundColor = Style.App.background

    // headerView
    headerView.addSubviews([
      addButton,
      backButton,
      saveButton,
      settingsButton,
      titleLabel,
      dividerView,
      refreshButton,
      removeAllButton
    ])

    // safeAreaHeaderView
    safeAreaHeaderView.backgroundColor = Style.Views.Header.Background
    safeAreaHeaderView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.topAnchor,
      right: view.rightAnchor)

    // headerView
    headerView.backgroundColor = Style.Views.Header.Background
    headerView.anchor(
      top: view.safeAreaLayoutGuide.topAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      heightConstant: Sizes.Views.Header.height)

    // backButton
    backButton.anchor(
      top: headerView.topAnchor,
      left: headerView.leftAnchor,
      bottom: headerView.bottomAnchor,
      leftConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 12
    )

    // addButton
    addButton.anchor(
      top: headerView.topAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 12
    )
    
    // saveButton
    saveButton.anchor(
      top: headerView.topAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 12
    )
    
    // settingsButton
    settingsButton.anchor(
      top: headerView.topAnchor,
      bottom: headerView.bottomAnchor,
      right: saveButton.leftAnchor,
      rightConstant: 8,
      widthConstant: UIScreen.main.bounds.width / 12
    )

    // refreshButton
    refreshButton.anchor(
      top: headerView.topAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 12
    )

    // removeAllButton
    removeAllButton.anchor(
      top: headerView.topAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 12
    )

    // titleLabel
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.textAlignment = .center
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(
      left: headerView.leftAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      leftConstant: UIScreen.main.bounds.width / 6,
      bottomConstant: 20,
      rightConstant: UIScreen.main.bounds.width / 6
    )

    // dividerView
    dividerView.backgroundColor = Style.Views.Header.Divider
    dividerView.anchor(
      left: headerView.leftAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      heightConstant: 1.0)
  }
}
