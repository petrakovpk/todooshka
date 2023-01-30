//
//  TDViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 30.09.2021.
//

import UIKit

class TDViewController: UIViewController {
  // MARK: - UI Elements
  public let headerView: UIView = {
    let view = UIView()
    view.backgroundColor = Style.Views.Header.Background
    return view
  }()
  
  public let backButton: UIButton = {
    let button = UIButton(type: .system)
    button.isHidden = true
    button.setImage(Icon.arrowLeft.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()
  
  public let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    label.textAlignment = .center
    return label
  }()

  public let addButton: UIButton = {
    let button = UIButton(type: .system)
    button.isHidden = true
    button.setImage(Icon.addSquare.image.template, for: .normal)
    button.tintColor = Style.App.text
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

  private let safeAreaHeaderView: UIView = {
    let view = UIView()
    view.backgroundColor = Style.Views.Header.Background
    return view
  }()
  
  private let dividerView: UIView = {
    let view = UIView()
    view.backgroundColor = Style.Views.Header.Divider
    return view
  }()

  // MARK: - Lifecycle
  open override func viewDidLoad() {
    super.viewDidLoad()
    configureHeader()
  }

  // MARK: - Configure
  private func configureHeader() {
    navigationItem.setHidesBackButton(true, animated: false)
    
    view.addSubviews([
      safeAreaHeaderView,
      headerView
    ])

    view.backgroundColor = Style.App.background

    headerView.addSubviews([
      backButton,
      titleLabel,
      addButton,
      saveButton,
      settingsButton,
      refreshButton,
      removeAllButton,
      dividerView
    ])

    safeAreaHeaderView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.topAnchor,
      right: view.rightAnchor
    )
  
    headerView.anchor(
      top: view.safeAreaLayoutGuide.topAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      heightConstant: Sizes.Views.Header.height)

    backButton.anchor(
      top: headerView.topAnchor,
      left: headerView.leftAnchor,
      bottom: headerView.bottomAnchor,
      leftConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 12
    )

    addButton.anchor(
      top: headerView.topAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 12
    )
    
    saveButton.anchor(
      top: headerView.topAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 12
    )
    
    settingsButton.anchor(
      top: headerView.topAnchor,
      bottom: headerView.bottomAnchor,
      right: saveButton.leftAnchor,
      rightConstant: 8,
      widthConstant: UIScreen.main.bounds.width / 12
    )

    refreshButton.anchor(
      top: headerView.topAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 12
    )

    removeAllButton.anchor(
      top: headerView.topAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 12
    )

    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(
      left: headerView.leftAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      leftConstant: UIScreen.main.bounds.width / 6,
      bottomConstant: 20,
      rightConstant: UIScreen.main.bounds.width / 6
    )

    dividerView.anchor(
      left: headerView.leftAnchor,
      bottom: headerView.bottomAnchor,
      right: headerView.rightAnchor,
      heightConstant: 1.0)
  }
}
