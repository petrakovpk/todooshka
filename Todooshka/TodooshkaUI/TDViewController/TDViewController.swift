//
//  TDViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 30.09.2021.
//

import UIKit

class TDViewController: UIViewController {
  
  //MARK: - UI Elements
  public let titleLabel = UILabel()
  public let headerView = UIView()
  public let backButton = UIButton(type: .custom)
  
  public let saveButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "tick-round")?.original, for: .normal)
    button.semanticContentAttribute = .forceRightToLeft
    button.layer.isHidden = true
    return button
  }()
  
  private let safeAreaHeaderView = UIView()
  private let dividerView = UIView()
  
  //MARK: - Lifecycle
  open override func viewDidLoad() {
    super.viewDidLoad()
    configureHeader()
  }
  
  //MARK: - Configure
  private func configureHeader() {
    
    //adding
    view.addSubview(safeAreaHeaderView)
    view.addSubview(headerView)
    
    headerView.addSubview(backButton)
    headerView.addSubview(saveButton)
    headerView.addSubview(titleLabel)
    headerView.addSubview(dividerView)
    
    // view
    view.backgroundColor = Theme.App.background

    // safeAreaHeaderView
    safeAreaHeaderView.backgroundColor = Theme.App.Header.background
    safeAreaHeaderView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor)

    // headerView
    headerView.backgroundColor = Theme.App.Header.background
    headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: 55.adjusted)
    
    // backButton
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // saveButton
    saveButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // titleLabel
    titleLabel.font = UIFont.systemFont(ofSize: 17.adjusted, weight: .medium)
    titleLabel.textAlignment = .center
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(left: backButton.rightAnchor, bottom: headerView.bottomAnchor, right: saveButton.leftAnchor, leftConstant: 0, bottomConstant: 20.adjusted, rightConstant: 0)
    
    // dividerView
    dividerView.backgroundColor = Theme.App.Header.dividerBackground
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    // backButton
    backButton.imageView?.tintColor = Theme.App.text
  }
}
