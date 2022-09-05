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

class TaskListViewController: UIViewController {
  
  // MARK: - Properties
  let disposeBag = DisposeBag()
  
  var collectionView: UICollectionView!
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>!
  var viewModel: TaskListViewModel!
  
  //MARK: - UI Elements
  private let headerView = UIView()
  private let backButton = UIButton(type: .custom)
  private let removeAllDeletedTasksButton = UIButton(type: .custom)
  private let addTaskButton = UIButton(type: .custom)
  private let titleLabel = UILabel()
  private let dividerView = UIView()
  
  // alert
  private let alertView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let alertSubView: UIView = {
    let view = UIView()
    view.cornerRadius = 27
    view.backgroundColor = Theme.App.background
    return view
  }()
  
  private let alertLabel: UILabel = {
    let label = UILabel(text: "")
    label.textColor = Theme.App.text
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 17.adjusted, weight: .medium)
    return label
  }()
  
  private let alertDeleteButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(hexString: "#FF005C")
    let attrString = NSAttributedString(string: "Удалить", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.adjusted, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let alertCancelButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.adjusted, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Theme.App.text?.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    collectionView = UICollectionView(frame: view.bounds , collectionViewLayout: createCompositionalLayout())
    
    view.addSubview(collectionView)
    view.addSubview(headerView)
    headerView.addSubview(titleLabel)
    headerView.addSubview(backButton)
    headerView.addSubview(addTaskButton)
    headerView.addSubview(removeAllDeletedTasksButton)
    headerView.addSubview(dividerView)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // headerView
    headerView.backgroundColor = UIColor(named: "navigationHeaderViewBackgroundColor")
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)
    
    // addTaskButton
    addTaskButton.isHidden = true
    addTaskButton.setImage(UIImage(named: "plus-custom"), for: .normal)
    addTaskButton.cornerRadius = addTaskButton.bounds.width / 2
    addTaskButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // removeAllButton
    removeAllDeletedTasksButton.isHidden = true 
    removeAllDeletedTasksButton.setImage(UIImage(named: "trash-custom")?.original, for: .normal)
    removeAllDeletedTasksButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // titleLabel
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)
    
    // backButton
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    backButton.imageView?.tintColor = Theme.App.text
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // dividerView
    dividerView.backgroundColor = UIColor(named: "navigationDividerViewBackgroundColor")
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    // collectionView
    collectionView.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.reuseID)
    collectionView.register(TaskReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskReusableView.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .clear
    collectionView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
  }
  
  private func configureAlert() {
    view.addSubview(alertView)
    alertView.addSubview(alertSubView)
    alertSubView.addSubview(alertLabel)
    alertSubView.addSubview(alertDeleteButton)
    alertSubView.addSubview(alertCancelButton)
    
    // alertView
    alertView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    // alertSubView
    alertSubView.anchor(widthConstant: 287.adjusted, heightConstant: 171.adjusted)
    alertSubView.anchorCenterXToSuperview()
    alertSubView.anchorCenterYToSuperview()
    
    // alertLabel
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * 171.adjusted / 4)
    
    // alertDeleteButton
    alertDeleteButton.anchor(widthConstant: 94.adjusted, heightConstant: 30.adjusted)
    alertDeleteButton.cornerRadius = 15.adjusted
    alertDeleteButton.anchorCenterXToSuperview()
    alertDeleteButton.anchorCenterYToSuperview(constant: 15.adjusted)
    
    // alertCancelButton
    alertCancelButton.anchor(top: alertDeleteButton.bottomAnchor, topConstant: 10.adjusted)
    alertCancelButton.anchorCenterXToSuperview()
  }
  
  //MARK: - Setup Collection View
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(62))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 5, trailing: 0)
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
  
  //MARK: - Bind To
  func bindViewModel() {
    
    let input = TaskListViewModel.Input(
      // selection
      selection: collectionView.rx.itemSelected.asDriver(),
      // alert
      alertDeleteButtonClick: alertDeleteButton.rx.tap.asDriver(),
      alertCancelButtonClick: alertCancelButton.rx.tap.asDriver(),
      // back
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      // add
      addTaskButtonClickTrigger: addTaskButton.rx.tap.asDriver(),
      // remove all
      removeAllDeletedTasksButtonClickTrigger: removeAllDeletedTasksButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.addTask.drive(),
      outputs.changeStatus.drive(),
      outputs.hideAlert.drive(hideAlertBinder),
      outputs.hideCell.drive(hideCellBinder),
      outputs.navigateBack.drive(),
      outputs.openTask.drive(),
      outputs.removeTask.drive(),
      outputs.setAlertText.drive(alertLabel.rx.text),
      outputs.setDataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.showAlert.drive(showAlertBinder),
      outputs.showAddTaskButton.drive(showAddTaskButtonBinder),
      outputs.showRemovaAllButton.drive(showRemovaAllButtonBinder)
    ]
      .forEach({ $0?.disposed(by: disposeBag) })
    
  }
  
  // MARK: - Binders
  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertView.isHidden = true
    })
  }
  
  var hideCellBinder: Binder<IndexPath> {
    return Binder(self, binding: { (vc, indexPath) in
      if let cell = vc.collectionView.cellForItem(at: indexPath) as? TaskCell {
        cell.hideSwipe(animated: true)
      }
    })
  }
  
  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertView.isHidden = false
    })
  }
  
  var showAddTaskButtonBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.addTaskButton.isHidden = false
    })
  }
  
  var showRemovaAllButtonBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.removeAllDeletedTasksButton.isHidden = false
    })
  }
  
  var addTaskButtonIsHiddenBinder: Binder<Bool> {
    return Binder(self, binding: { (vc, isHidden) in
      vc.addTaskButton.isHidden = isHidden
    })
  }
  
  var removeAllDeletedTasksButtonIsHiddenBinder: Binder<Bool> {
    return Binder(self, binding: { (vc, isHidden) in
      vc.removeAllDeletedTasksButton.isHidden = isHidden
    })
  }
  
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>(configureCell: { dataSource, collectionView, indexPath, item in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.reuseID, for: indexPath) as! TaskCell
      cell.configure(with: dataSource[indexPath.section].mode)
      cell.configure(with: item.task)
      cell.configure(with: item.type)
      cell.delegate = self
      cell.repeatButton.rx.tap.map{ _ -> IndexPath? in indexPath }.asDriver(onErrorJustReturn: nil).drive(self.repeatButtonBinder).disposed(by: self.disposeBag)
      return cell
    }, configureSupplementaryView: { dataSource , collectionView, kind, indexPath in
      let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskReusableView.reuseID, for: indexPath) as! TaskReusableView
      section.configure(text: dataSource[indexPath.section].header)
      return section
    })
  }
  
  var repeatButtonBinder: Binder<IndexPath?> {
    return Binder(self, binding: { (vc, indexPath) in
      guard let indexPath = indexPath else { return }
      self.viewModel.changeStatus(indexPath: indexPath, status: .InProgress, completed: nil)
    })
  }
  
}


extension TaskListViewController: SwipeCollectionViewCellDelegate {
  
  func collectionView(_ collectionView: UICollectionView, willBeginEditingItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) {
    viewModel.editingIndexPath = indexPath
  }
  
  func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
    viewModel.editingIndexPath = nil
  }
  
  func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }
    
    let deleteAction = SwipeAction(style: .destructive, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.viewModel.changeStatus(indexPath: indexPath, status: .Deleted, completed: nil)
    }
    
    let ideaBoxAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.viewModel.changeStatus(indexPath: indexPath, status: .Idea, completed: nil)
    }
    
    let completeTaskAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.viewModel.changeStatus(indexPath: indexPath, status: .Completed, completed: Date())
    }
    
    configure(action: deleteAction, with: .trash)
    configure(action: ideaBoxAction, with: .idea)
    configure(action: completeTaskAction, with: .complete)
    
    deleteAction.backgroundColor = Theme.App.background
    ideaBoxAction.backgroundColor = Theme.App.background
    completeTaskAction.backgroundColor = Theme.App.background
    
    return [completeTaskAction, deleteAction, ideaBoxAction]
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

