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

class FunViewController: TDViewController {
  private let disposeBag = DisposeBag()
  public var viewModel: FunViewModel!
  
  // MARK: - UI Elements
  private var tableView: UITableView! {
    didSet {
      tableView.delegate = self
      tableView.dataSource = nil
      tableView.isPagingEnabled = true
      tableView.showsVerticalScrollIndicator = false
      tableView.backgroundColor = .clear
      tableView.separatorStyle = .none
      tableView.translatesAutoresizingMaskIntoConstraints = false
      tableView.contentInsetAdjustmentBehavior = .never
      tableView.register(AddMoreFunCell.self, forCellReuseIdentifier: AddMoreFunCell.reuseID)
      tableView.register(FunCell.self, forCellReuseIdentifier: FunCell.reuseID)
    }
  }
  
  private var dataSource: RxTableViewSectionedAnimatedDataSource<FunSection>!
  
  private var upvoteButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Upvote", for: .normal)
    button.setTitleColor(.systemGreen, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private var downvoteButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Downvote", for: .normal)
    button.setTitleColor(.systemRed, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
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
    headerView.layer.zPosition = 2
    titleLabel.text = "It's fun"
    
    tableView = UITableView(frame: .zero)
    
    view.addSubviews([tableView, downvoteButton, upvoteButton])
    
    downvoteButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      widthConstant: (UIScreen.main.bounds.width - 16 * 3) / 2)
    
    upvoteButton.anchor(
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      bottomConstant: 16,
      rightConstant: 16,
      widthConstant: (UIScreen.main.bounds.width - 16 * 3) / 2)
    
    tableView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: downvoteButton.topAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 8,
      rightConstant: 16
    )
  }
  
  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = FunViewModel.Input(
      downvoteButtonTap: downvoteButton.rx.tap.asDriver(),
      upvoteButtonTap: upvoteButton.rx.tap.asDriver(),
      scrollTrigger: tableView.rx.didEndDecelerating.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
  
    [
      outputs.navigateToAuth.drive(),
      outputs.reloadData.drive(),
      outputs.loadMoreData.drive(),
      outputs.scrollToNextCell.drive(scrollToNextCellBinder),
      outputs.saveReaction.drive(),
      outputs.saveView.drive(),
      outputs.dataSource.drive(tableView.rx.items(dataSource: dataSource)),
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  var scrollToNextCellBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      let currentIndexPath = vc.tableView.indexPathsForVisibleRows?.last ?? IndexPath(row: 0, section: 0)
      let nextSection = currentIndexPath.section + 1
      
      if nextSection < vc.dataSource.sectionModels.count {
        let nextIndexPath = IndexPath(row: 0, section: nextSection)
        vc.tableView.scrollToRow(at: nextIndexPath, at: .top, animated: true)
      }
    })
  }
  
  var currentVisibleItemRelayBinder: Binder<FunItem> {
    return Binder(self, binding: { vc, funItem in
//      switch funItemType {
//      case .noMoreTasks:
//        self.upvoteButton.isSelected = false
//        self.downvoteButton.isSelected = false
//      case .task(let taskItem):
//        switch taskItem.reactionType {
//        case .upvote:
//          self.upvoteButton.isSelected = true
//          self.downvoteButton.isSelected = false
//        case .downvote:
//          self.upvoteButton.isSelected = false
//          self.downvoteButton.isSelected = true
//        case .skip:
//          self.upvoteButton.isSelected = true
//          self.downvoteButton.isSelected = true
//        case nil:
//          self.upvoteButton.isSelected = false
//          self.downvoteButton.isSelected = false
//        }
//      }
    })
  }
  
  func configureDataSource() {
    dataSource = RxTableViewSectionedAnimatedDataSource<FunSection>(
      configureCell: {_, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: FunCell.reuseID, for: indexPath) as! FunCell
        cell.configure(with: item)
        return cell
      })
  }
}


extension FunViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.bounds.height
  }
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    self.scrollViewDidEndDecelerating(scrollView)
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let currentIndexPath = tableView.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
    let visibleItem = dataSource[currentIndexPath.section].items[currentIndexPath.row]
    
    guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows else { return }
    
    if indexPathsForVisibleRows.count == 1 {
      viewModel.scrolledUpperVisibleIndexPath.accept(nil)
      viewModel.scrolledVisibleIndexPath.accept(IndexPath(row: 0, section: 0))
    } else {
      viewModel.scrolledUpperVisibleIndexPath.accept(indexPathsForVisibleRows[safe: 0])
      viewModel.scrolledVisibleIndexPath.accept(indexPathsForVisibleRows[safe: 1])
    }
  }
  
  func scrollToNextItem() {
      let currentIndexPath = tableView.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
      let nextRow = currentIndexPath.row + 1
      let nextIndexPath = IndexPath(row: nextRow, section: currentIndexPath.section)

      if nextRow < self.dataSource[currentIndexPath.section].items.count {
          self.tableView.scrollToRow(at: nextIndexPath, at: .top, animated: true)
      }
  }
}
