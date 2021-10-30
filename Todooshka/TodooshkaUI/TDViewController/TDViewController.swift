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
  
  //MARK: - Lifecycle
  open override func viewDidLoad() {
    super.viewDidLoad()
    configureViewController()
  }
  
  //MARK: - Configure
  private func configureViewController() {
    headerView.backgroundColor = UIColor(named: "navigationBarBackground")
    
    let safeAreaHeaderView = UIView()
    safeAreaHeaderView.backgroundColor = UIColor(named: "navigationBarBackground")
    
    view.addSubview(safeAreaHeaderView)
    safeAreaHeaderView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor)
    
    view.addSubview(headerView)
    headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: 55.adjusted)
    
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    
    headerView.addSubview(backButton)
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    headerView.addSubview(saveButton)
    saveButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    titleLabel.font = UIFont.systemFont(ofSize: 17.adjusted, weight: .medium)
    titleLabel.textAlignment = .center
    
    headerView.addSubview(titleLabel)
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(left: backButton.rightAnchor, bottom: headerView.bottomAnchor, right: saveButton.leftAnchor, leftConstant: 0, bottomConstant: 20.adjusted, rightConstant: 0)
    
    let dividerView = UIView()
    dividerView.backgroundColor = UIColor(named: "navigationBarDividerBackground")
    
    headerView.addSubview(dividerView)
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    view.backgroundColor = UIColor(named: "appBackground")
    backButton.imageView?.tintColor = UIColor(named: "appText")
  }
  
}
