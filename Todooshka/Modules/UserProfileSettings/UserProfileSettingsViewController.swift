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
import Firebase

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
    button.setTitleColor(UIColor(named: "appText")!.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    configureColor()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    let headerView = UIView()
    headerView.backgroundColor = UIColor(named: "navigationHeaderViewBackgroundColor")
    
    view.addSubview(headerView)
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)
    
    let titleLabel = UILabel()
    
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.text = "Настройки и конфеденциальность"
    
    headerView.addSubview(titleLabel)
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)
    
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    backButton.imageView?.tintColor = UIColor(named: "appText")
    
    headerView.addSubview(backButton)
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    let dividerView = UIView()
    dividerView.backgroundColor = UIColor(named: "navigationDividerViewBackgroundColor")
    
    headerView.addSubview(dividerView)
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    tableView = UITableView(frame: .zero, style: .grouped)
    tableView.register(UserProfileSettingsCell.self, forCellReuseIdentifier: UserProfileSettingsCell.reuseID)
    
    view.addSubview(tableView)
    tableView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
  }
  
  private func configureAlert() {
    view.addSubview(alertBackgroundView)
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    let alertWindowView = UIView()
    alertWindowView.cornerRadius = 27
    alertWindowView.backgroundColor = UIColor(named: "appBackground")
    
    alertBackgroundView.addSubview(alertWindowView)
    alertWindowView.anchor(widthConstant: 287, heightConstant: 171)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()
    
    let alertLabel = UILabel(text: "Выйти из системы?")
    alertLabel.textColor = UIColor(named: "appText")
    alertLabel.textAlignment = .center
    alertLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    
    alertWindowView.addSubview(alertLabel)
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * 171 / 4)
    
    alertWindowView.addSubview(logoutAlertButton)
    logoutAlertButton.anchor(widthConstant: 94, heightConstant: 30)
    logoutAlertButton.cornerRadius = 15
    logoutAlertButton.anchorCenterXToSuperview()
    logoutAlertButton.anchorCenterYToSuperview(constant: 15)
    
    alertWindowView.addSubview(cancelAlertButton)
    cancelAlertButton.anchor(top: logoutAlertButton.bottomAnchor, topConstant: 10)
    cancelAlertButton.anchorCenterXToSuperview()
  }
  //MARK: - Bind To
  func bindTo(with viewModel: UserProfileSettingsViewModel) {
    self.viewModel = viewModel
    
    backButton.rx.tap.bind { viewModel.leftBarButtonBackItemClick() }.disposed(by: disposeBag)
    logoutAlertButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.alertLogoutButtonClicked() }.disposed(by: disposeBag)
    cancelAlertButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.alertCancelButtonClicked() }.disposed(by: disposeBag)
    
    viewModel.showAlert.bind{ [weak self] showAlert in
      guard let self = self else { return }
      self.alertBackgroundView.isHidden = !showAlert
    }.disposed(by: disposeBag)
    
  }
  
  func configureDataSource() {
    tableView.dataSource = nil
    dataSource = RxTableViewSectionedReloadDataSource<UserProfileSettingsSectionModel> { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileSettingsCell.reuseID, for: indexPath) as! UserProfileSettingsCell
      cell.configure(imageName: item.imageName, text: item.text)
      return cell
    }
    
    viewModel.dataSource.asDriver()
      .drive(tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected.bind{ [weak self] indexPath in
      guard let self = self else  { return }
      self.viewModel.itemSelected(indexPath: indexPath)
    }.disposed(by: disposeBag)
  }
  
}
