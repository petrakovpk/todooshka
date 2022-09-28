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
  
  // MARK: - UI Elements
  private let logOutButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Выйти из аккаунта", for: .normal)
    button.setTitleColor(.red, for: .normal)
    button.cornerRadius = 15
    button.borderWidth = 1
    button.borderColor = UIColor.systemRed
    return button
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.reloadData.accept(())
  }
  
  // MARK: - Configure UI
  func configureUI() {
    
    // tableView
    tableView = UITableView(frame: .zero, style: .plain)
    tableView.backgroundColor = Theme.App.background
    
    // adding
    view.addSubview(tableView)
    view.addSubview(logOutButton)

    
    // view
    view.backgroundColor = Theme.App.background

    // titleLabel
    titleLabel.text = "Настройки и конфеденциальность"

    // logOutButton
    logOutButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, leftConstant: 16, bottomConstant: 16, rightConstant: 16, heightConstant: 50)
    
    // tableView
    tableView.register(UserProfileCell.self, forCellReuseIdentifier: UserProfileCell.reuseID)
    tableView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: logOutButton.topAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)

  }
  
  //MARK: - Bind To
  func bindViewModel() {
    let input = UserProfileViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      logOutButtonClickTrigger: logOutButton.rx.tap.asDriver(),
      selection: tableView.rx.itemSelected.asDriver()
    )
    let output = viewModel.transform(input: input)
    
    [
      output.dataSource.drive(tableView.rx.items(dataSource: dataSource)),
      output.itemSelected.drive(),
      output.logOut.drive(),
      output.navigateBack.drive(),
      output.title.drive(titleLabel.rx.text),
    ]
      .forEach{ $0.disposed(by: disposeBag) }
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


