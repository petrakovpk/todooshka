//
//  QuestImagePresentationViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.05.2023.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift
import AnyImageKit

class QuestImagePresentationViewController: UIViewController {
  public var viewModel: QuestImagePresentationViewModel!
  
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
    let input = QuestImagePresentationViewModel.Input(
      selection: tableView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.sections.drive(tableView.rx.items(dataSource: dataSource)),
      outputs.selectionHandler.drive()
      
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
