//
//  ThemeSettingsViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.11.2022.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class ThemeSettingsViewController: UIViewController {
  
  public var viewModel: ThemeSettingsViewModel!
  
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Element
  private var tableView: UITableView!
  private var dataSource: RxTableViewSectionedReloadDataSource<SettingsCellSectionModel>!
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    label.textAlignment = .center
    label.text = "Настройки"
    return label
  }()
  
  private let titleDividerView: UIView = {
    let view = UIView()
    view.backgroundColor = Style.Views.Header.Divider
    return view
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  func configureUI() {
    view.backgroundColor = Style.App.background
    
    // init
    tableView = UITableView(frame: .zero, style: .grouped)
    tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseID)
    tableView.backgroundColor = .clear
    
    // adding
    view.addSubviews([
      titleLabel,
      titleDividerView,
      tableView
    ])
    
    // titleLabel
    titleLabel.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16
    )
    
    // titleDividerView
    titleDividerView.anchor(
      top: titleLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      heightConstant: 1.0
    )
    
    // tableView
    tableView.anchor(
      top: titleDividerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
    
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
    
        let input = ThemeSettingsViewModel.Input(
          selection: tableView.rx.itemSelected.asDriver()
        )
    
        let outputs = viewModel.transform(input: input)
    
        [
          outputs.dataSource.drive(tableView.rx.items(dataSource: dataSource)),
          outputs.delete.drive()
        ]
          .forEach { $0.disposed(by: disposeBag) }
    
    
  }
  
  var modeBinder: Binder<OpenViewControllerMode> {
    return Binder(self, binding: { vc, mode in
      
    })
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
