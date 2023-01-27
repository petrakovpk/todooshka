//
//  TaskListViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 16.06.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwipeCellKit

class TaskListViewController: TDViewController {
  public var viewModel: TaskListViewModel!

  private let disposeBag = DisposeBag()

  private var collectionView: UICollectionView!
  private var dataSource: [TaskListSection] = []

  private let alertView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()

  private let alertSubView: UIView = {
    let view = UIView()
    view.cornerRadius = 27
    view.backgroundColor = Style.App.background
    return view
  }()

  private let alertLabel: UILabel = {
    let label = UILabel(text: "")
    label.textColor = Style.App.text
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    return label
  }()

  private let alertDeleteButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Удалить",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
    )
    let button = UIButton(type: .custom)
    button.backgroundColor = Style.Buttons.AlertRoseButton.Background
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()

  private let alertCancelButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Style.App.text?.withAlphaComponent(0.5), for: .normal)
    return button
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    backButton.isHidden = false
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())

    view.addSubview(collectionView)

    collectionView.register(
      TaskCell.self,
      forCellWithReuseIdentifier: TaskCell.reuseID)
    collectionView.register(
      TaskReusableView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: TaskReusableView.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .clear
    collectionView.dataSource = self

    collectionView.anchor(
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
    view.addSubviews([
      alertView
    ])
    
    alertView.addSubviews([
      alertSubView
    ])
    
    alertSubView.addSubviews([
      alertLabel,
      alertDeleteButton,
      alertCancelButton
    ])

    alertView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.bottomAnchor,
      right: view.rightAnchor
    )

    alertSubView.anchorCenterXToSuperview()
    alertSubView.anchorCenterYToSuperview()
    alertSubView.anchor(widthConstant: Sizes.Views.AlertDeleteView.width, heightConstant: Sizes.Views.AlertDeleteView.height)
    
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * Sizes.Views.AlertDeleteView.height / 4)

    alertDeleteButton.anchorCenterXToSuperview()
    alertDeleteButton.anchorCenterYToSuperview(constant: 15)
    alertDeleteButton.anchor(widthConstant: Sizes.Buttons.AlertOkButton.width, heightConstant: Sizes.Buttons.AlertOkButton.height)
    alertDeleteButton.cornerRadius = Sizes.Buttons.AlertOkButton.height / 2

    alertCancelButton.anchorCenterXToSuperview()
    alertCancelButton.anchor(top: alertDeleteButton.bottomAnchor, topConstant: 10)
  }

  // MARK: - Setup Collection View
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }

  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(62))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 5, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 0, trailing: 0)
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)
    section.boundarySupplementaryItems = [header]
    return section
  }

  // MARK: - Bind To
  func bindViewModel() {
    let input = TaskListViewModel.Input(
      // BACK
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      // ADD
      addTaskButtonClickTrigger: addButton.rx.tap.asDriver(),
      // REMOVE ALL
      removeAllButtonClickTrigger: removeAllButton.rx.tap.asDriver(),
      // SELECT TASK
      selection: collectionView.rx.itemSelected.asDriver(),
      // ALERT
      alertDeleteButtonClick: alertDeleteButton.rx.tap.asDriver(),
      alertCancelButtonClick: alertCancelButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      // HEADER
      outputs.title.drive(titleLabel.rx.text),
      // NAVIGATE BACK
      outputs.navigateBack.drive(),
      // ADD TASK
      outputs.addTask.drive(),
    //  outputs.addTaskButtonIsHidden.drive(addButton.rx.isHidden),
      // MODE
      outputs.mode.drive(modeBinder),
      // REMOVE ALL TASKS
      outputs.removeAllTasks.drive(),
    //  outputs.removeAllTasksButtonIsHidden.drive(removeAllButton.rx.isHidden),
      // DATASOURCE
      outputs.dataSource.drive(dataSourceBinder),
      outputs.hideCellWhenAlertClosed.drive(hideCellBinder),
      // TASK
      outputs.openTask.drive(),
      outputs.changeTaskStatus.drive(),
      outputs.removeTask.drive(),
      // ALERT
      outputs.alertText.drive(alertLabel.rx.text),
      outputs.showAlert.drive(showAlertBinder),
      outputs.hideAlert.drive(hideAlertBinder),
    ]
      .forEach({ $0?.disposed(by: disposeBag) })
  }

  // MARK: - Binders
  var dataSourceBinder: Binder<[TaskListSection]> {
    return Binder(self, binding: { _, dataSource in
      self.dataSource = dataSource
      self.collectionView.reloadData()
    })
  }

  var modeBinder: Binder<TaskListMode> {
    return Binder(self, binding: { vc, mode in
      switch mode {
      case .idea:
        vc.addButton.isHidden = false
      case .deleted:
        vc.removeAllButton.isHidden = false
      default:
        return
      }
    })
  }
  
  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertView.isHidden = false
    })
  }
  
  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertView.isHidden = true
    })
  }

  var hideCellBinder: Binder<IndexPath> {
    return Binder(self, binding: { vc, indexPath in
      if let cell = vc.collectionView.cellForItem(at: indexPath) as? TaskCell {
        cell.hideSwipe(animated: true)
      }
    })
  }
  
  var repeatButtonBinder: Binder<IndexPath?> {
    return Binder(self, binding: { vc, indexPath in
      guard let indexPath = indexPath else { return }
      vc.viewModel.changeStatusTrigger.accept(ChangeStatus(completed: nil, indexPath: indexPath, status: .inProgress))
    })
  }
}

// MARK: - UICollectionViewDelegate
extension TaskListViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDelegate
extension TaskListViewController: UICollectionViewDelegateFlowLayout {
}

// MARK: - UICollectionViewDataSource
extension TaskListViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    dataSource.count
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    dataSource[section].items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: TaskCell.reuseID,
      for: indexPath
    ) as? TaskCell else { return UICollectionViewCell() }
    let item = dataSource[indexPath.section].items[indexPath.item]
    cell.configure(mode: dataSource[indexPath.section].mode, task: item.task, kindOfTask: item.kindOfTask)
    cell.delegate = self
    cell.repeatButton.rx.tap
      .map { _ -> IndexPath in indexPath }
      .asDriver(onErrorJustReturn: nil)
      .drive(self.repeatButtonBinder)
      .disposed(by: cell.disposeBag)
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let section = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: TaskReusableView.reuseID,
      for: indexPath
    ) as? TaskReusableView else { return UICollectionReusableView() }
    section.configure(text: dataSource[indexPath.section].header)
    return section
  }
}

extension TaskListViewController: SwipeCollectionViewCellDelegate {

  func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }

    let deleteAction = SwipeAction(style: .destructive, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.viewModel.changeStatusTrigger.accept(ChangeStatus(completed: nil, indexPath: indexPath, status: .deleted))
    }

    let ideaBoxAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.viewModel.changeStatusTrigger.accept(ChangeStatus(completed: nil, indexPath: indexPath, status: .idea))
    }

    configure(action: deleteAction, with: .trash)
    configure(action: ideaBoxAction, with: .idea)

    deleteAction.backgroundColor = Style.App.background
    ideaBoxAction.backgroundColor = Style.App.background

    return [deleteAction, ideaBoxAction]
  }

  func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    var options = SwipeOptions()
    options.expansionStyle = .destructive
    options.transitionStyle = .border
    options.buttonSpacing = 4
    return options
  }

  func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
    let buttonDisplayMode: ButtonDisplayMode = .imageOnly
    let buttonStyle: ButtonStyle = .circular

    action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
    action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode, size: CGSize(width: 44, height: 44))

    switch buttonStyle {
    case .backgroundColor:
      action.backgroundColor = descriptor.color(forStyle: buttonStyle)
    case .circular:
      action.backgroundColor = .clear
      action.textColor = descriptor.color(forStyle: buttonStyle)
      action.font = .systemFont(ofSize: 9)
      action.transitionDelegate = ScaleTransition.default
    }
  }
}
