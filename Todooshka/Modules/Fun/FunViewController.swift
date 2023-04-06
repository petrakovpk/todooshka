//
//  FeedViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 18.11.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture

class FunViewController: TDViewController {
  private let disposeBag = DisposeBag()
  private var isLoading: Bool = true
  public var viewModel: FunViewModel!
  
  // MARK: - UI Elements
  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero)
    tableView.isPagingEnabled = true
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    tableView.contentInsetAdjustmentBehavior = .never
    return tableView
  }()
  
  private let badButton: UIButton = {
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 5
    button.backgroundColor = Palette.SingleColors.BrinkPink
    button.setTitle("Не очень", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return button
  }()
  
  private let goodButton: UIButton = {
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 5
    button.backgroundColor = Palette.SingleColors.Shamrock
    button.setTitle("Одобряем", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return button
  }()
  
  private var dataSource: RxTableViewSectionedReloadDataSource<FunSection>!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  // MARK: - Configure UI
  private func configureUI() {
    headerView.layer.zPosition = 2
    titleLabel.text = "It's fun"
    
    view.addSubviews([tableView, badButton, goodButton])
    
    setupLayout()
    tableView.delegate = self
    tableView.register(FunSectionCell.self, forCellReuseIdentifier: FunSectionCell.reuseID)
  }
  
  private func setupLayout() {
    let screenWidth = UIScreen.main.bounds.width
    
    badButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      widthConstant: screenWidth / 2 - 16 - 8,
      heightConstant: 50
    )
    
    goodButton.anchor(
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      bottomConstant: 16,
      rightConstant: 16,
      widthConstant: screenWidth / 2 - 16 - 8,
      heightConstant: 50
    )
    
    tableView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: badButton.topAnchor,
      right: view.rightAnchor,
      topConstant: 0,
      leftConstant: 0,
      bottomConstant: 0,
      rightConstant: 0
    )
  }
  
  // MARK: - Bind ViewModel
  private func bindViewModel() {
    let input = FunViewModel.Input(
      viewDidLoad: rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).mapToVoid()
    )
    
    let outputs = viewModel.transform(input: input)
    outputs.dataSource.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
  }
  
  // MARK: - Configure DataSource
  private func configureDataSource() {
    tableView.dataSource = nil
    dataSource = RxTableViewSectionedReloadDataSource<FunSection>(configureCell: { dataSource, tableView, indexPath, item in
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: FunSectionCell.reuseID,
        for: indexPath
      ) as? FunSectionCell else { return UITableViewCell() }
      cell.configure(with: item)
      return cell
    })
  }
}

// MARK: - UITableViewDelegate
extension FunViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    tableView.frame.height
  }
}

