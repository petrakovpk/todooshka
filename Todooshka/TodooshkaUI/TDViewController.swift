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
    button.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()

  public let saveButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(named: "tick-round")?.original, for: .normal)
    button.isHidden = true
    return button
  }()

  public let addButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(named: "plus-custom")?.original, for: .normal)
    button.isHidden = true
    return button
  }()

  public let refreshButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(named: "rotate-right")?.template, for: .normal)
    button.tintColor = Style.App.text
    button.isHidden = true
    return button
  }()

  public let removeAllButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(named: "trash-custom")?.original, for: .normal)
    button.isHidden = true
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
      titleLabel,
      dividerView,
      refreshButton,
      removeAllButton
    ])

    // safeAreaHeaderView
    safeAreaHeaderView.backgroundColor = Style.Views.Header.Background
    safeAreaHeaderView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor)

    // headerView
    headerView.backgroundColor = Style.Views.Header.Background
    headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: Sizes.Views.Header.height)

    // backButton
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)

    // addButton
    addButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)

    // saveButton
    saveButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)

    // refreshButton
    refreshButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)

    // removeAllButton
    removeAllButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)

    // titleLabel
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.textAlignment = .center
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(left: backButton.rightAnchor, bottom: headerView.bottomAnchor, right: saveButton.leftAnchor, leftConstant: 0, bottomConstant: 20, rightConstant: 0)

    // dividerView
    dividerView.backgroundColor = Style.Views.Header.Divider
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,     heightConstant: 1.0)
  }
}
