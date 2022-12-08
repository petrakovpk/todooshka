//
//  SettingsViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//

import RxCocoa
import RxDataSources
import RxFlow
import RxSwift
import UIKit

class SettingsViewController: TDViewController {
  // MARK: - Properties
  let disposeBag = DisposeBag()

  var tableView: UITableView!
  var viewModel: SettingsViewModel!
  var dataSource: RxTableViewSectionedReloadDataSource<SettingsCellSectionModel>!

  // MARK: - UI Elements
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()

  private let logoutAlertButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Выйти",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
    )
    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(hexString: "#FF005C")
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()

  private let cancelAlertButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Отмена",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
    )
    let button = UIButton(type: .custom)
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Style.App.text!.withAlphaComponent(0.5), for: .normal)
    return button
  }()

  private let alertWindowView = UIView()
  private let alertLabel = UILabel(text: "Выйти из системы?")

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
    titleLabel.text = "Настройки и конфеденциальность"
    backButton.isHidden = false
    
    // tableView
    tableView = UITableView(frame: .zero, style: .grouped)

    // adding
    view.addSubview(tableView)

    // tableView
    tableView.backgroundColor = .clear
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
    alertWindowView.backgroundColor = Style.App.background
    alertWindowView.anchor(widthConstant: 287, heightConstant: 171)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()

    // alertLabel
    alertLabel.textColor = Style.App.text
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
  // MARK: - Bind To
  func bindViewModel() {
    let input = SettingsViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      selection: tableView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.backButtonClick.drive(),
      outputs.itemSelected.drive(),
      outputs.dataSource.drive(tableView.rx.items(dataSource: dataSource))
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }

  func configureDataSource() {
    tableView.dataSource = nil
    dataSource = RxTableViewSectionedReloadDataSource<SettingsCellSectionModel>(configureCell: { _, tableView, indexPath, item in
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: SettingsCell.reuseID,
        for: indexPath
      ) as? SettingsCell else { return UITableViewCell() }
      cell.configure(image: item.image, text: item.text)
      return cell
    }, titleForHeaderInSection: { dataSource, index in
      return dataSource.sectionModels[index].header
    })
  }
}
