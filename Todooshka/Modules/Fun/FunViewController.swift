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
  public var viewModel: FunViewModel!
  
  // MARK: - UI Elements
  private var tableView: UITableView!
  private var dataSource: RxTableViewSectionedReloadDataSource<FunSection>!
  
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
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    tableView = UITableView(frame: .zero)
    
    headerView.layer.zPosition = 2
    titleLabel.text = "It's fun"
    
    view.addSubviews([
      tableView,
      badButton,
      goodButton
    ])

    badButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 2 - 16 - 8,
      heightConstant: 50
    )
    
    goodButton.anchor(
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      bottomConstant: 16,
      rightConstant: 16,
      widthConstant: UIScreen.main.bounds.width / 2 - 16 - 8,
      heightConstant: 50
    )
    
    tableView.delegate = self
    tableView.isPagingEnabled = true
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    tableView.translatesAutoresizingMaskIntoConstraints = false  // Enable Auto Layout
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.register(
      FunSectionCell.self,
      forCellReuseIdentifier: FunSectionCell.reuseID)
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
  func bindViewModel() {
    let input = FunViewModel.Input(
//      authorImageClickTrigger: authorImageView.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
//      authorNameClickTrigger: authorNameLabel.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
//      taskTextClickTrigger: taskTextLabel.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      badButtonClickTrigger: badButton.rx.tap.asDriver(),
      goodButtonClickTrigger: goodButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
  //    outputs.nextTask.drive(nextTaskBinder),
     // outputs.nextTaskImage.drive(contentImageView.rx.image),
      outputs.handleReaction.drive(),
      outputs.dataSource.drive(tableView.rx.items(dataSource: dataSource))
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  func configureDataSource() {
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
  
//  var nextTaskBinder: Binder<Task> {
//    return Binder(self, binding: { vc, task in
//      vc.taskTextLabel.text = task.text
//    })
//  }
  
}


extension FunViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    tableView.height
  }
}
