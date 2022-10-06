//
//  KindOfTaskListViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import RxDataSources
import SwipeCellKit

class KindOfTaskListViewController: TDViewController {
  
  //MARK: - Properties
  let disposeBag = DisposeBag()
  
  var collectionView: UICollectionView!
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskListSection>!
  var viewModel: KindOfTaskListViewModel!
  
  let itemMoved = BehaviorRelay<ItemMovedEvent?>(value: nil)
  
  //MARK: - UI Elements
  private let descriptionLabel = UILabel()
 
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let alertLabel = UILabel()
  
  private let deleteAlertButton: UIButton = {
    let attrString = NSAttributedString(string: "Удалить", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    let button = UIButton(type: .custom)
    button.backgroundColor = Theme.Buttons.AlertRoseButton.Background
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let cancelAlertButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Theme.App.text!.withAlphaComponent(0.5) , for: .normal)
    return button
  }()

  private let alertWindowView = UIView()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }

  //MARK: - Configure UI
  func configureUI() {
    
    // settings
    addButton.isHidden = false
    
    // collectionView
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubview(descriptionLabel)
    view.addSubview(collectionView)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // descriptionLabel
    descriptionLabel.text = "Перетащите типы в нужном порядке:"
    descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    descriptionLabel.textColor = Theme.App.text
    descriptionLabel.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, topConstant: 25, leftConstant: 16)
    
    // collectionView
    collectionView.backgroundColor = .clear
    collectionView.dragInteractionEnabled = true
    collectionView.dragDelegate = self
    collectionView.dropDelegate = self
    collectionView.register(KindOfTaskListCell.self, forCellWithReuseIdentifier: KindOfTaskListCell.reuseID)
    collectionView.register(KindOfTaskListReusableCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: KindOfTaskListReusableCell.reuseID)
    collectionView.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
  }
  
  private func configureAlert() {
    
    // adding
    view.addSubview(alertBackgroundView)
    alertBackgroundView.addSubview(alertWindowView)
    alertWindowView.addSubview(alertLabel)
    alertWindowView.addSubview(deleteAlertButton)
    alertWindowView.addSubview(cancelAlertButton)
    
    // alertBackgroundView
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    // alertWindowView
    alertWindowView.cornerRadius = 27
    alertWindowView.backgroundColor = Theme.App.background
    alertWindowView.anchor(widthConstant: 287, heightConstant: 171)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()
    
    // alertLabel
    alertLabel.text = "Удалить тип?"
    alertLabel.textColor = Theme.App.text
    alertLabel.textAlignment = .center
    alertLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * 171 / 4)
    
    // deleteAlertButton
    deleteAlertButton.anchor(widthConstant: 94, heightConstant: 30)
    deleteAlertButton.cornerRadius = 15
    deleteAlertButton.anchorCenterXToSuperview()
    deleteAlertButton.anchorCenterYToSuperview(constant: 15)
    
    // cancelAlertButton
    cancelAlertButton.anchor(top: deleteAlertButton.bottomAnchor, topConstant: 10)
    cancelAlertButton.anchorCenterXToSuperview()
  }

  //MARK: - Bind To
  func bindViewModel() {
    
    let input = KindOfTaskListViewModel.Input(
      addButtonClickTrigger: addButton.rx.tap.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      cancelAlertButtonClickTrigger: cancelAlertButton.rx.tap.asDriver(),
      deleteAlertButtonClickTrigger: deleteAlertButton.rx.tap.asDriver(),
      moving: itemMoved.asDriver(),
      selection: collectionView.rx.itemSelected.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.addTask.drive(),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.hideAlert.drive(hideAlertBinder),
      outputs.navigateBack.drive(),
      outputs.moving.drive(),
      outputs.openKindOfTask.drive(),
      outputs.removeKindOfTask.drive(),
      outputs.showAlert.drive(showAlertBinder),
    ]
      .forEach({$0.disposed(by: disposeBag)})
  }
  
  // MARK: - Binders
  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertBackgroundView.isHidden = true
    })
  }
  
  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertBackgroundView.isHidden = false
    })
  }

  // MARK: - Setup CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(45))
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
  
  //MARK: - Color CollectionView
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskListSection>(
      configureCell: {(_, collectionView, indexPath, kindOfTask) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KindOfTaskListCell.reuseID, for: indexPath) as! KindOfTaskListCell
        cell.delegate = self
        cell.configure(with: kindOfTask, mode: .Empty)
        return cell
      }, configureSupplementaryView: { dataSource , collectionView, kind, indexPath in
        let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: KindOfTaskListReusableCell.reuseID, for: indexPath) as! KindOfTaskListReusableCell
        section.configure(text: dataSource[indexPath.section].header)
        return section
      })
  }
}


//MARK: - UICollectionViewDragDelegate
extension KindOfTaskListViewController: UICollectionViewDragDelegate {
  func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    let item = dataSource[indexPath.section].items[indexPath.item]
    let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    dragItem.localObject = item
    return [dragItem]
  }
}

//MARK: - UICollectionViewDropDelegate
extension KindOfTaskListViewController: UICollectionViewDropDelegate {
  
  func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
    if collectionView.hasActiveDrag {
      return UICollectionViewDropProposal(operation: .move,intent: .insertAtDestinationIndexPath )
    }
    return UICollectionViewDropProposal(operation: .forbidden)
  }
  
  func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
    
    if let destinationIndexPath = coordinator.destinationIndexPath,
       let sourceIndexPath = coordinator.items[0].sourceIndexPath {
      self.itemMoved.accept((sourceIndex: sourceIndexPath, destinationIndex: destinationIndexPath))
    }
  }
}

// MARK: - SwipeCollectionViewCellDelegate
extension KindOfTaskListViewController: SwipeCollectionViewCellDelegate {

  func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

    guard orientation == .right else { return nil }

    let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
      action.fulfill(with: .reset)
      self.viewModel.removeKindOfTaskIsRequired(indexPath: indexPath)
    }

    configure(action: deleteAction, with: .trash)
    deleteAction.backgroundColor = Theme.App.background
    return [deleteAction]
  }

  func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    var options = SwipeOptions()
    options.expansionStyle = .destructive
    options.transitionStyle = .border
    return options
  }

  func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
    let buttonDisplayMode: ButtonDisplayMode = .imageOnly
    let buttonStyle: ButtonStyle = .circular

    action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
    action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode, size: CGSize(width: 30, height: 30))

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
