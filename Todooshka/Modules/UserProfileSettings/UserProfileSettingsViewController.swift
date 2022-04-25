//
//  UserProfileSettingsViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import RxDataSources

class UserProfileSettingsViewController: UIViewController {
  
  //MARK: - Properties
  let disposeBag = DisposeBag()
  
  var tableView: UITableView!
  var viewModel: UserProfileSettingsViewModel!
  var dataSource: RxTableViewSectionedReloadDataSource<UserProfileSettingsSectionModel>!
  
  //MARK: - UI Elements
  private let backButton = UIButton(type: .custom)
  
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let logoutAlertButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(hexString: "#FF005C")
    let attrString = NSAttributedString(string: "Выйти", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let cancelAlertButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Theme.App.text!.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  private let headerView = UIView()
  private let titleLabel = UILabel()
  private let dividerView = UIView()
  private let alertWindowView = UIView()
  private let alertLabel = UILabel(text: "Выйти из системы?")
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    
    // tableView
    tableView = UITableView(frame: .zero, style: .grouped)
    
    // adding
    view.addSubview(headerView)
    view.addSubview(tableView)
    headerView.addSubview(titleLabel)
    headerView.addSubview(backButton)
    headerView.addSubview(dividerView)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // headerView
    headerView.backgroundColor = UIColor(named: "navigationHeaderViewBackgroundColor")
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)
    
    // titleLabel
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.text = "Настройки и конфеденциальность"
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)
    
    // backButton
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    backButton.imageView?.tintColor = Theme.App.text
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // dividerView
    dividerView.backgroundColor = UIColor(named: "navigationDividerViewBackgroundColor")
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    // tableView
    tableView.backgroundColor = .clear
    tableView.register(UserProfileSettingsCell.self, forCellReuseIdentifier: UserProfileSettingsCell.reuseID)
    tableView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
  }
  
  private func configureAlert() {
    
    // adding
    view.addSubview(alertBackgroundView)
    alertBackgroundView.addSubview(alertWindowView)
    alertWindowView.addSubview(alertLabel)
    alertWindowView.addSubview(logoutAlertButton)
    alertWindowView.addSubview(cancelAlertButton)
    
    // alertBackgroundView
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    // alertWindowView
    alertWindowView.cornerRadius = 27
    alertWindowView.backgroundColor = Theme.App.background
    alertWindowView.anchor(widthConstant: 287, heightConstant: 171)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()
    
    // alertLabel
    alertLabel.textColor = Theme.App.text
    alertLabel.textAlignment = .center
    alertLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * 171 / 4)
    
    // logoutAlertButton
    logoutAlertButton.anchor(widthConstant: 94, heightConstant: 30)
    logoutAlertButton.cornerRadius = 15
    logoutAlertButton.anchorCenterXToSuperview()
    logoutAlertButton.anchorCenterYToSuperview(constant: 15)
    
    // cancelAlertButton
    cancelAlertButton.anchor(top: logoutAlertButton.bottomAnchor, topConstant: 10)
    cancelAlertButton.anchorCenterXToSuperview()
  }
  //MARK: - Bind To
  func bindViewModel() {
    
    let input = UserProfileSettingsViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      selection: tableView.rx.itemSelected.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.backButtonClick.drive(),
      outputs.itemSelected.drive(),
      outputs.dataSource.drive(tableView.rx.items(dataSource: dataSource))
    ]
      .forEach({$0.disposed(by: disposeBag)})
  }
  
  func configureDataSource() {
    tableView.dataSource = nil
    dataSource = RxTableViewSectionedReloadDataSource<UserProfileSettingsSectionModel> (configureCell: { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileSettingsCell.reuseID, for: indexPath) as! UserProfileSettingsCell
      cell.configure(imageName: item.imageName, text: item.text)
      return cell
    },  titleForHeaderInSection: { dataSource, index in
      return dataSource.sectionModels[index].header
    })
    
    
  }
  
}
