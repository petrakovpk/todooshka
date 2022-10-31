//
//  UserProfileViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 09.09.2022.
//

import RxCocoa
import RxDataSources
import RxFlow
import RxSwift
import UIKit

class UserProfileViewController: TDViewController {
  
  // MARK: - Properties
  let disposeBag = DisposeBag()
  var dataSource: RxTableViewSectionedReloadDataSource<UserProfileSection>!
  var tableView: UITableView!
  var viewModel: UserProfileViewModel!
  
  // MARK: - Alert
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let alertWindowView: UIView = {
    let view = UIView()
    view.cornerRadius = 27
    view.backgroundColor = Style.App.background
    return view
  }()
  
  private let alertLabel: UILabel = {
    let label = UILabel(text: "Выйти из аккаунта?")
    label.textColor = Style.App.text
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    return label
  }()
  
  private let alertOkButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Выйти",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
    )
    let button = UIButton(type: .custom)
    button.backgroundColor = Style.Buttons.AlertRoseButton.Background
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let alertCancelButton: UIButton = {
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    let button = UIButton(type: .custom)
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Style.App.text!.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.reloadData.accept(())
  }
  
  // MARK: - Configure UI
  func configureUI() {
    
    // tableView
    tableView = UITableView(frame: .zero, style: .plain)
    tableView.backgroundColor = Style.App.background
    
    // adding
    view.addSubview(tableView)

    // view
    view.backgroundColor = Style.App.background

    // titleLabel
    titleLabel.text = "Настройки и конфеденциальность"

    // tableView
    tableView.register(UserProfileCell.self, forCellReuseIdentifier: UserProfileCell.reuseID)
    tableView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)

  }
  
  func configureAlert() {
    
    // adding
    view.addSubview(alertBackgroundView)
    alertBackgroundView.addSubview(alertWindowView)
    alertWindowView.addSubview(alertLabel)
    alertWindowView.addSubview(alertOkButton)
    alertWindowView.addSubview(alertCancelButton)
    
    // alertView
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    // alertSubView
    alertWindowView.anchor(widthConstant: Sizes.Views.alertLogOutView.width, heightConstant: Sizes.Views.alertLogOutView.height)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()
    
    // alertLabel
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * Sizes.Views.alertLogOutView.height / 4)

    // alertOkButton
    alertOkButton.anchor(widthConstant: Sizes.Buttons.alertOkButton.width, heightConstant: Sizes.Buttons.alertOkButton.height)
    alertOkButton.cornerRadius = 15
    alertOkButton.anchorCenterXToSuperview()
    alertOkButton.anchorCenterYToSuperview(constant: 15)
    
    // alertCancelButton
    alertCancelButton.anchor(top: alertOkButton.bottomAnchor, topConstant: 10)
    alertCancelButton.anchorCenterXToSuperview()
  }
  
  //MARK: - Bind To
  func bindViewModel() {
    let input = UserProfileViewModel.Input(
      alertCancelButtonClickTrigger: alertCancelButton.rx.tap.asDriver(),
      alertOkButtonClickTrigger: alertOkButton.rx.tap.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      selection: tableView.rx.itemSelected.asDriver()
    )
    let output = viewModel.transform(input: input)
    
    [
      output.dataSource.drive(tableView.rx.items(dataSource: dataSource)),
      output.itemSelected.drive(),
      output.hideLogOffAlert.drive(hideLogOffAlertBinder),
      output.logOut.drive(),
      output.navigateBack.drive(),
      output.showLogOffAlert.drive(showAlerLogOffBinder),
      output.title.drive(titleLabel.rx.text),
    ]
      .forEach{ $0.disposed(by: disposeBag) }
  }
  
  var hideLogOffAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertBackgroundView.isHidden = true
    })
  }
  
  var showAlerLogOffBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertBackgroundView.isHidden = false
    })
  }
  
  func configureDataSource() {
    tableView.dataSource = nil
    dataSource = RxTableViewSectionedReloadDataSource<UserProfileSection> (configureCell: { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileCell.reuseID, for: indexPath) as! UserProfileCell
      cell.configure(leftText: item.leftText, rightText: item.rightText)
      return cell
    },  titleForHeaderInSection: { dataSource, index in
      return dataSource.sectionModels[index].header
    })
  }
}


