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
  let logOffAlertController: UIAlertController = {
    let alert = UIAlertController(title: nil, message: "Вы уверены?", preferredStyle: .actionSheet)
    // alert.addAction(UIAlertAction(title: "Выйти",style: .destructive, handler: nil))
    //  alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
    return alert
  }()
  
  private let backButton = UIButton(type: .custom)
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    setViewColor()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    let headerView = UIView()
    headerView.backgroundColor = UIColor(named: "navigationHeaderViewBackgroundColor")
    
    view.addSubview(headerView)
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)
    
    let titleLabel = UILabel()
    
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.text = "Settings and privacy"
    
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
  
  //MARK: - Bind To
  func bindTo(with viewModel: UserProfileSettingsViewModel) {
    self.viewModel = viewModel
    
    backButton.rx.tap.bind { viewModel.leftBarButtonBackItemClick() }.disposed(by: disposeBag)
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
    
    
    tableView.rx.itemSelected.bind { [weak self] indexPath in
      guard let self = self else  { return }
      
      switch indexPath.item {
      case 1:
        if Auth.auth().currentUser != nil {
          let actions: [UIAlertController.AlertAction] = [
            .action(title: "Выйти", style: .destructive),
            .action(title: "Отмена", style: .cancel)
          ]
          
          UIAlertController
            .present(in: self, title: nil, message: "Вы уверены?", style: .actionSheet, actions: actions)
            .subscribe(onNext: { buttonIndex in
              self.viewModel.alertButtonClick(buttonIndex: buttonIndex)
            })
            .disposed(by: self.disposeBag)
        } else {
          self.viewModel.logUserIn()
        }
      default:
        self.viewModel.itemSelected(indexPath: indexPath)
      }
    }.disposed(by: self.disposeBag)
  }
  
}
