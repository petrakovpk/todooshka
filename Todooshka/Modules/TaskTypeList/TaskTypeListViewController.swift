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
    button.setTitleColor(UIColor(named: "appText")!.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    configureColor()
    configureGestures()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
  }
 
  //MARK: - Configure UI
  func configureUI() {
    
    let headerView = UIView()
    headerView.backgroundColor = UIColor(named: "navigationBarBackground")
    
    view.addSubview(headerView)
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)
    
    addTaskTypeButton.cornerRadius = addTaskTypeButton.bounds.width / 2
    
    headerView.addSubview(addTaskTypeButton)
    addTaskTypeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    titleLabel.text = "Типы задач"
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.textAlignment = .center
    titleLabel.textColor = UIColor(named: "appText")
    
    headerView.addSubview(titleLabel)
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)
    
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    backButton.imageView?.tintColor = UIColor(named: "appText")
    
    headerView.addSubview(backButton)
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    let dividerView = UIView()
    dividerView.backgroundColor = UIColor(named: "navigationBarDividerBackground")
    
    headerView.addSubview(dividerView)
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    descriptionLabel.text = "Перетащите типы в нужном порядке:"
    descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    descriptionLabel.textColor = UIColor(named: "appText")
    
    view.addSubview(descriptionLabel)
    descriptionLabel.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, topConstant: 25, leftConstant: 16)
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    collectionView.register(TaskTypeListCollectionViewCell.self, forCellWithReuseIdentifier: TaskTypeListCollectionViewCell.reuseID)
    collectionView.register(TaskTypeListCollectionReusableViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskTypeListCollectionReusableViewCell.reuseID)
    
    collectionView.backgroundColor = UIColor.clear
    collectionView.dragInteractionEnabled = true
    collectionView.dragDelegate = self
    collectionView.dropDelegate = self
    
    view.addSubview(collectionView)
    collectionView.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
  }
  
  private func configureAlert() {
    view.addSubview(alertBackgroundView)
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    let alertWindowView = UIView()
    alertWindowView.cornerRadius = 27
    alertWindowView.backgroundColor = UIColor(named: "appBackground")
    
    alertBackgroundView.addSubview(alertWindowView)
    alertWindowView.anchor(widthConstant: 287, heightConstant: 171)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()
    
   
    alertLabel.textColor = UIColor(named: "appText")
    alertLabel.textAlignment = .center
    alertLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    
    alertWindowView.addSubview(alertLabel)
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * 171 / 4)
    
    alertWindowView.addSubview(deleteAlertButton)
    deleteAlertButton.anchor(widthConstant: 94, heightConstant: 30)
    deleteAlertButton.cornerRadius = 15
    deleteAlertButton.anchorCenterXToSuperview()
    deleteAlertButton.anchorCenterYToSuperview(constant: 15)
    
    alertWindowView.addSubview(cancelAlertButton)
    cancelAlertButton.anchor(top: deleteAlertButton.bottomAnchor, topConstant: 10)
    cancelAlertButton.anchorCenterXToSuperview()
  }
  
  private func configureGestures() {
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
    swipeRight.direction = .right
    self.view.addGestureRecognizer(swipeRight)
  }
  
  @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
    
    if let swipeGesture = gesture as? UISwipeGestureRecognizer {

      switch swipeGesture.direction {
      case .right:
        viewModel.leftBarButtonBackItemClick()
      case .down:
        print("Swiped down")
      case .left:
        print("Swiped left")
      case .up:
        print("Swiped up")
      default:
        break
      }
    }
  }
  
  
  //MARK: - Bind To
  func bindTo(with viewModel: TaskTypesListViewModel) {
    self.viewModel = viewModel
    backButton.rx.tap.bind{ viewModel.leftBarButtonBackItemClick() }.disposed(by: disposeBag)
    addTaskTypeButton.rx.tap.bind{ viewModel.addTaskTypeButtonClick() }.disposed(by: disposeBag)
    
    deleteAlertButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.alertDeleteButtonClicked() }.disposed(by: disposeBag)
    cancelAlertButton.rx.tapGesture().when(.recognized).bind{ _ in
      viewModel.alertCancelButtonClicked() }.disposed(by: disposeBag)
    
    viewModel.alertLabelOutput.bind(to: alertLabel.rx.text).disposed(by: disposeBag)
    
    viewModel.showAlert.bind{ [weak self] showAlert in
      guard let self = self else { return }
      self.alertBackgroundView.isHidden = !showAlert
    }.disposed(by: disposeBag)
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
        cell.bindTo(viewModel: cellViewModel)
        return cell
      }, configureSupplementaryView: { dataSource , collectionView, kind, indexPath in
        let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskTypeListCollectionReusableViewCell.reuseID, for: indexPath) as! TaskTypeListCollectionReusableViewCell
        section.configure(text: dataSource[indexPath.section].header)
        return section
      })
    
    viewModel.dataSource.asDriver()
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.bind{ self.viewModel.collectionViewItemSelected(indexPath: $0) }.disposed(by: disposeBag)
  }
}

//MARK: - ConfigureColorProtocol
extension TaskTypesListViewController: ConfigureColorProtocol {
  func configureColor() {
    view.backgroundColor = UIColor(named: "appBackground")
    collectionView.backgroundColor = .clear
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
      viewModel.collectionViewItemMoved(sourceIndex: sourceIndexPath, destinationIndex: destinationIndexPath)
    }
  }
}
