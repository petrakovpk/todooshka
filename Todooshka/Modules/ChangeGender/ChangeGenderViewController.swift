//
//  ChangeGenderViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ChangeGenderViewController: TDViewController {
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  var dataSource: RxTableViewSectionedReloadDataSource<ChangeGenderSectionModel>!
  var tableView: UITableView!

  // MARK: - MVVM
  public var viewModel: ChangeGenderViewModel!

  // MARK: - UI Elemenets
  private let textField: UITextField = {
    let textField = UITextField()
    textField.borderWidth = 1.0
    textField.borderColor = Style.App.text
    textField.cornerRadius = 5
    return textField
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    // settings
    backButton.isHidden = false
    headerSaveButton.isHidden = false

    // tableView
    tableView = UITableView(frame: .zero, style: .plain)
    tableView.backgroundColor = Style.App.background

    // adding
    view.addSubview(tableView)

    //  header
    titleLabel.text = "Выберите пол"

    // tableView
    tableView.register(ChangeGenderCell.self, forCellReuseIdentifier: ChangeGenderCell .reuseID)
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

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = ChangeGenderViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      saveButtonClickTrigger: headerSaveButton.rx.tap.asDriver(),
      selection: tableView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.dataSource.drive(tableView.rx.items(dataSource: dataSource)),
      outputs.itemSelected.drive(),
      outputs.navigateBack.drive(),
      outputs.save.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }

  func configureDataSource() {
    tableView.dataSource = nil
    dataSource = RxTableViewSectionedReloadDataSource<ChangeGenderSectionModel>(configureCell: { _, tableView, indexPath, item in
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: ChangeGenderCell.reuseID,
        for: indexPath
      ) as? ChangeGenderCell else { return UITableViewCell() }
      cell.configure(text: item.gender.rawValue, isSelected: item.isSelected)
      return cell
    }, titleForHeaderInSection: { dataSource, index in
      dataSource.sectionModels[index].header
    })
  }
}
