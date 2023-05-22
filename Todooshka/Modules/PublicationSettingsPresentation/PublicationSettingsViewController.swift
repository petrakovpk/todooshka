//
//  PublicationSettingsViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 09.05.2023.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class PublicationSettingsViewController: UIViewController {
  public var viewModel: PublicationSettingsViewModel!
  
  private let disposeBag = DisposeBag()
  
  private var tableView: UITableView!
  private var dataSource: RxTableViewSectionedReloadDataSource<SettingSection>!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  func configureUI() {
    tableView = UITableView(frame: .zero, style: .grouped)
    
    view.backgroundColor = Style.App.background
    
    view.addSubviews([
      tableView
    ])

    tableView.backgroundColor = .clear
    tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseID)
    tableView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
  }
  
  func bindViewModel() {
    let input = PublicationSettingsViewModel.Input(
      selection: tableView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.settingSections.drive(tableView.rx.items(dataSource: dataSource)),
      outputs.edit.drive(),
      outputs.unpublish.drive(),
      outputs.remove.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  func configureDataSource() {
    tableView.dataSource = nil
    dataSource = RxTableViewSectionedReloadDataSource<SettingSection>(configureCell: { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseID, for: indexPath) as! SettingsCell
      cell.configure(item: item)
      return cell
    }, titleForHeaderInSection: { dataSource, index in
      return dataSource.sectionModels[index].header
    })
  }
  
}

