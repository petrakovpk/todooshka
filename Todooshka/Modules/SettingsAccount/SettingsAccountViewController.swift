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

class SettingsAccountViewController: TDViewController {
  public var viewModel: SettingsAccountViewModel!
  
  private let disposeBag = DisposeBag()
  
  private var tableView: UITableView!
  private var dataSource: RxTableViewSectionedReloadDataSource<SettingSection>!

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
    button.setTitleColor(Style.App.text!.withAlphaComponent(0.5), for: .normal)
    return button
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    // header
    backButton.isHidden = false
    titleLabel.text = "Настройки аккаунта"
    
    // tableView
    tableView = UITableView(frame: .zero, style: .plain)
    tableView.backgroundColor = Style.App.background

    // adding
    view.addSubview(tableView)
    
    // tableView
    tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseID)
    tableView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
  }

  func configureAlert() {
    view.addSubviews([alertBackgroundView])
    alertBackgroundView.addSubviews([alertWindowView])
    alertWindowView.addSubviews([alertLabel, alertOkButton, alertCancelButton])

    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)

    alertWindowView.anchor(widthConstant: Sizes.Views.AlertLogOutView.width, heightConstant: Sizes.Views.AlertLogOutView.height)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()

    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * Sizes.Views.AlertLogOutView.height / 4)

    alertOkButton.anchor(widthConstant: Sizes.Buttons.AlertOkButton.width, heightConstant: Sizes.Buttons.AlertOkButton.height)
    alertOkButton.cornerRadius = 15
    alertOkButton.anchorCenterXToSuperview()
    alertOkButton.anchorCenterYToSuperview(constant: 15)

    alertCancelButton.anchor(top: alertOkButton.bottomAnchor, topConstant: 10)
    alertCancelButton.anchorCenterXToSuperview()
  }

  // MARK: - Bind To
  func bindViewModel() {
    let input = SettingsAccountViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      // table view
      selection: tableView.rx.itemSelected.asDriver(),
      // alert
      alertCancelButtonClickTrigger: alertCancelButton.rx.tap.asDriver(),
      alertOkButtonClickTrigger: alertOkButton.rx.tap.asDriver()
    )
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.navigateBack.drive(),
      outputs.settingsSections.drive(tableView.rx.items(dataSource: dataSource)),
      outputs.logOut.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }

//    [
//      output.dataSource.drive(tableView.rx.items(dataSource: dataSource)),
//      output.itemSelected.drive(),
//      output.hideLogOffAlert.drive(hideLogOffAlertBinder),
//      output.logOut.drive(),
//      output.navigateBack.drive(),
//      output.showLogOffAlert.drive(showAlerLogOffBinder),
//      output.title.drive(titleLabel.rx.text)
//    ]
//      .forEach { $0.disposed(by: disposeBag) }
  }

  var hideLogOffAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertBackgroundView.isHidden = true
    })
  }

  var showAlerLogOffBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertBackgroundView.isHidden = false
    })
  }

  func configureDataSource() {
    tableView.dataSource = nil
    dataSource = RxTableViewSectionedReloadDataSource<SettingSection>(configureCell: { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseID, for: indexPath) as! SettingsCell
      cell.configure(item: item)
      return cell
    }, titleForHeaderInSection: { dataSource, index in
      dataSource.sectionModels[index].header
    })
  }
}