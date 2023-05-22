//
//  KindListViewController.swift
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

class KindListViewController: TDViewController {
  public var viewModel: KindListViewModel!
  
  private let disposeBag = DisposeBag()
  private let itemMoved = BehaviorRelay<ItemMovedEvent?>(value: nil)
  
  // MARK: - UI Elements
  private let descriptionLabel = UILabel()

  private let alertContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()

  private let alertLabel = UILabel()

  private let alertDeleteButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Удалить",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    let button = UIButton(type: .custom)
    button.backgroundColor = Style.Buttons.AlertRoseButton.Background
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()

  private let alertCancelButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Отмена",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    let button = UIButton(type: .custom)
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Style.App.text!.withAlphaComponent(0.5), for: .normal)
    return button
  }()

  private let alertWindowView = UIView()
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<KindListSection>!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    backButton.isHidden = false
    headerSaveButton.isHidden = true

    // collectionView
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())

    // adding
    view.addSubview(descriptionLabel)
    view.addSubview(collectionView)

    // view
    view.backgroundColor = Style.App.background

    // descriptionLabel
    descriptionLabel.text = "Перетащите типы в нужном порядке:"
    descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    descriptionLabel.textColor = Style.App.text
    descriptionLabel.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, topConstant: 25, leftConstant: 16)

    // collectionView
    collectionView.backgroundColor = .clear
    collectionView.dragInteractionEnabled = true
    collectionView.dragDelegate = self
    collectionView.dropDelegate = self
    collectionView.register(
      KindListCell.self,
      forCellWithReuseIdentifier: KindListCell.reuseID
    )
    collectionView.register(
      KindListReusableCell.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: KindListReusableCell.reuseID
    )
    collectionView.anchor(
      top: descriptionLabel.bottomAnchor,
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
    // adding
    view.addSubview(alertContainerView)
    alertContainerView.addSubview(alertWindowView)
    alertWindowView.addSubview(alertLabel)
    alertWindowView.addSubview(alertDeleteButton)
    alertWindowView.addSubview(alertCancelButton)

    // alertBackgroundView
    alertContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)

    // alertWindowView
    alertWindowView.cornerRadius = 27
    alertWindowView.backgroundColor = Style.App.background
    alertWindowView.anchor(widthConstant: 287, heightConstant: 171)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()

    // alertLabel
    alertLabel.text = "Удалить тип?"
    alertLabel.textColor = Style.App.text
    alertLabel.textAlignment = .center
    alertLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * 171 / 4)

    // deleteAlertButton
    alertDeleteButton.anchor(widthConstant: 94, heightConstant: 30)
    alertDeleteButton.cornerRadius = 15
    alertDeleteButton.anchorCenterXToSuperview()
    alertDeleteButton.anchorCenterYToSuperview(constant: 15)

    // cancelAlertButton
    alertCancelButton.anchor(top: alertDeleteButton.bottomAnchor, topConstant: 10)
    alertCancelButton.anchorCenterXToSuperview()
  }

  // MARK: - Bind To
  func bindViewModel() {
    if viewModel.kindListMode == .deleted {
      removeAllButton.isHidden = false
      descriptionLabel.isHidden = true
      addButton.isHidden = true
      titleLabel.text = "Удаленные типы"
    } else {
      removeAllButton.isHidden = true
      descriptionLabel.isHidden = false
      addButton.isHidden = false
      titleLabel.text = "Типы"
    }

    let input = KindListViewModel.Input(
      // header buttons
      addButtonClickTrigger: addButton.rx.tap.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      removeAllButtonClickTrigger: removeAllButton.rx.tap.asDriver(),
      // kind list
      kindSelected: collectionView.rx.itemSelected.asDriver() ,
      kindMoved: itemMoved.asDriver().compactMap { $0 } ,
      // alert
      alertCancelButtonClickTrigger: alertCancelButton.rx.tap.asDriver(),
      alertDeleteButtonClickTrigger: alertDeleteButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      // header
      outputs.navigateBack.drive(),
      outputs.addKind.drive(),
      // kind list
      outputs.kindListSections.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.kindListOpenKind.drive(),
      outputs.kindListMoveItem.drive(),
      // alert
      outputs.alertIsHidden.drive(alertContainerView.rx.isHidden),
      // kind
      outputs.kindRemove.drive(),
      outputs.kindRemoveAllDeleted.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }

  }

  // MARK: - Binders
  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertContainerView.isHidden = true
    })
  }

  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertContainerView.isHidden = false
    })
  }

  // MARK: - Setup CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }

  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(45))
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

  // MARK: - Color CollectionView
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<KindListSection>(
      configureCell: {_, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: KindListCell.reuseID,
          for: indexPath
        ) as? KindListCell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.configure(with: item)
        return cell
      }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
        guard let section = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: KindListReusableCell.reuseID,
          for: indexPath
        ) as? KindListReusableCell else { return UICollectionReusableView() }
        section.configure(text: dataSource[indexPath.section].header)
        return section
      })
  }
}

// MARK: - UICollectionViewDragDelegate
extension KindListViewController: UICollectionViewDragDelegate {
  func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    let item = dataSource[indexPath.section].items[indexPath.item]
    let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    dragItem.localObject = item
    return [dragItem]
  }
}

// MARK: - UICollectionViewDropDelegate
extension KindListViewController: UICollectionViewDropDelegate {
  func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
    if collectionView.hasActiveDrag {
      return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath )
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
extension KindListViewController: SwipeCollectionViewCellDelegate {
  func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }

    let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
      action.fulfill(with: .reset)
      self.viewModel.swipeDeleteButtonClickTrigger.accept(indexPath)
    }

    configure(action: deleteAction, with: .trash)
    deleteAction.backgroundColor = Style.App.background
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
    let buttonStyle: SwipeButtonStyle = .circular

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
