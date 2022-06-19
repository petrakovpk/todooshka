//
//  TaskTypesListViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import RxDataSources

class TaskTypesListViewController: UIViewController {
  
  //MARK: - Properties
  let disposeBag = DisposeBag()
  
  var collectionView: UICollectionView!
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>!
  var viewModel: TaskTypesListViewModel!
  
  let itemMoved = BehaviorRelay<ItemMovedEvent?>(value: nil)
  
  //MARK: - UI Elements
  private let titleLabel = UILabel()
  private let descriptionLabel = UILabel()
  private let backButton = UIButton(type: .custom)
  private let addTaskTypeButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "plus-custom"), for: .normal)
    return button
  }()
  
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let alertLabel = UILabel()
  
  private let deleteAlertButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(hexString: "#FF005C")
    let attrString = NSAttributedString(string: "Удалить", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
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
  
  private let headerView = UIView()
  private let dividerView = UIView()
  private let alertWindowView = UIView()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    
    // collectionView
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubview(headerView)
    view.addSubview(descriptionLabel)
    view.addSubview(collectionView)
    headerView.addSubview(addTaskTypeButton)
    headerView.addSubview(titleLabel)
    headerView.addSubview(backButton)
    headerView.addSubview(dividerView)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // headerView
    headerView.backgroundColor = Theme.App.Header.background
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)
    
    // addTaskTypeButton
    addTaskTypeButton.cornerRadius = addTaskTypeButton.bounds.width / 2
    addTaskTypeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // titleLabel
    titleLabel.text = "Типы задач"
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.textAlignment = .center
    titleLabel.textColor = Theme.App.text
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)
    
    // backButton
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    backButton.imageView?.tintColor = Theme.App.text
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // dividerView
    dividerView.backgroundColor = Theme.App.Header.dividerBackground
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
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
    collectionView.register(TaskTypeListCollectionViewCell.self, forCellWithReuseIdentifier: TaskTypeListCollectionViewCell.reuseID)
    collectionView.register(TaskTypeListCollectionReusableViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskTypeListCollectionReusableViewCell.reuseID)
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
    
    let input = TaskTypesListViewModel.Input(
      
      // buttons
      addButtonClickTrigger: addTaskTypeButton.rx.tap.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      
      // alert
      deleteAlertButtonClickTrigger: deleteAlertButton.rx.tap.asDriver(),
      cancelAlertButtonClickTrigger: cancelAlertButton.rx.tap.asDriver(),
      
      // items
      selection: collectionView.rx.itemSelected.asDriver(),
      moving: itemMoved.asDriver().compactMap{$0}
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      // buttons
      outputs.addTypeButtonClick.drive(),
      outputs.backButtonClick.drive(),
      
      // dataSource
      outputs.selection.drive(),
      outputs.moving.drive(),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      
      // alert
      outputs.alertIsHidden.drive(alertBackgroundView.rx.isHidden),
      outputs.alertCancelButtonClick.drive(),
      outputs.alertDeleteButtonClick.drive()
    ]
      .forEach({$0.disposed(by: disposeBag)})
  }
  
  var showAlertBinder: Binder<Bool> {
    return Binder(self, binding: { (vc, showAlert) in
      vc.alertBackgroundView.isHidden = !showAlert
    })
  }
  
  //MARK: - Setup CollectionView
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
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>(
      configureCell: {(_, collectionView, indexPath, type) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeListCollectionViewCell.reuseID, for: indexPath) as! TaskTypeListCollectionViewCell
        let cellViewModel = TaskTypeListCollectionViewCellModel(services: self.viewModel.services, type: type)
        cell.viewModel = cellViewModel
        return cell
      }, configureSupplementaryView: { dataSource , collectionView, kind, indexPath in
        let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskTypeListCollectionReusableViewCell.reuseID, for: indexPath) as! TaskTypeListCollectionReusableViewCell
        section.configure(text: dataSource[indexPath.section].header)
        return section
      })
  }
}


//MARK: - UICollectionViewDragDelegate
extension TaskTypesListViewController: UICollectionViewDragDelegate {
  func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    let item = dataSource[indexPath.section].items[indexPath.item]
    let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    dragItem.localObject = item
    return [dragItem]
  }
}

//MARK: - UICollectionViewDropDelegate
extension TaskTypesListViewController: UICollectionViewDropDelegate {
  
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
