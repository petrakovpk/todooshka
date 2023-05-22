//
//  FollowersViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import RxCocoa
import RxDataSources
import RxFlow
import RxSwift
import UIKit

class FollowersViewController: TDViewController {
  public var viewModel: FollowersViewModel!
  
  private let disposeBag = DisposeBag()

  private var tableView: UITableView!
  private var dataSource: RxTableViewSectionedReloadDataSource<FollowersSection>!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  // MARK: - Configure UI
  func configureUI() {
    // header
    titleLabel.text = "Подписчики"
    backButton.isHidden = false
    
    // tableView
    tableView = UITableView(frame: .zero, style: .plain)

    // adding
    view.addSubview(tableView)

    // tableView
    tableView.delegate = self
    tableView.backgroundColor = .clear
    tableView.register(FollowersCell.self, forCellReuseIdentifier: FollowersCell.reuseID)
    tableView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      rightConstant: 16
    )
  }
  // MARK: - Bind To
  func bindViewModel() {
    let input = FollowersViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      // header
      outputs.navigateBack.drive(),
      // subscriptions
      outputs.followersSections.drive(tableView.rx.items(dataSource: dataSource))
      
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  func configureDataSource() {
    tableView.dataSource = nil
    dataSource = RxTableViewSectionedReloadDataSource<FollowersSection>(configureCell: { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: FollowersCell.reuseID, for: indexPath) as! FollowersCell
      cell.configure(with: item)
      return cell
    })
  }
}


extension FollowersViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50.0
  }
}
