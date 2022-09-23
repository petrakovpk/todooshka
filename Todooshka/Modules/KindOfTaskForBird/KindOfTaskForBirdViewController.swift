//
//  KindOfTaskForBirdViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 22.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwipeCellKit

class KindOfTaskForBirdViewController: TDViewController {
  
  // MARK: - Properties
  let disposeBag = DisposeBag()
  
  var collectionView: UICollectionView!
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskListSection>!
  var viewModel: KindOfTaskForBirdViewModel!

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
    
    // titleLabel
    titleLabel.text = "Типы задач"

    // collection view
    collectionView = UICollectionView(frame: view.bounds , collectionViewLayout: createCompositionalLayout())

    view.addSubview(collectionView)

    // collectionView
    collectionView.register(KindOfTaskListCell.self, forCellWithReuseIdentifier: KindOfTaskListCell.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .clear
    collectionView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
  }
  
  private func configureAlert() {
//    view.addSubview(alertView)
//    alertView.addSubview(alertSubView)
//    alertSubView.addSubview(alertLabel)
//    alertSubView.addSubview(alertDeleteButton)
//    alertSubView.addSubview(alertCancelButton)
//
//    // alertView
//    alertView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
//
//    // alertSubView
//    alertSubView.anchor(widthConstant: 287.adjusted, heightConstant: 171.adjusted)
//    alertSubView.anchorCenterXToSuperview()
//    alertSubView.anchorCenterYToSuperview()
//
//    // alertLabel
//    alertLabel.anchorCenterXToSuperview()
//    alertLabel.anchorCenterYToSuperview(constant: -1 * 171.adjusted / 4)
//
//    // alertDeleteButton
//    alertDeleteButton.anchor(widthConstant: 94.adjusted, heightConstant: 30.adjusted)
//    alertDeleteButton.cornerRadius = 15.adjusted
//    alertDeleteButton.anchorCenterXToSuperview()
//    alertDeleteButton.anchorCenterYToSuperview(constant: 15.adjusted)
//
//    // alertCancelButton
//    alertCancelButton.anchor(top: alertDeleteButton.bottomAnchor, topConstant: 10.adjusted)
//    alertCancelButton.anchorCenterXToSuperview()
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
    
    let input = KindOfTaskForBirdViewModel.Input(
      // selection
//      selection: collectionView.rx.itemSelected.asDriver(),
//      // alert
//      alertDeleteButtonClick: alertDeleteButton.rx.tap.asDriver(),
//      alertCancelButtonClick: alertCancelButton.rx.tap.asDriver(),
      // back
      backButtonClickTrigger: backButton.rx.tap.asDriver()
      // add
//      addTaskButtonClickTrigger: addButton.rx.tap.asDriver(),
//      // remove all
//      removeAllButtonClickTrigger: removeAllButton.rx.tap.asDriver()
    )
//
    let outputs = viewModel.transform(input: input)

    [
//      outputs.addTask.drive(),
//      outputs.change.drive(changeBinder),
//      outputs.hideAlert.drive(hideAlertBinder),
//      outputs.hideCell.drive(hideCellBinder),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.navigateBack.drive()
//      outputs.openTask.drive(),
//      outputs.removeAllTasks.drive(),
//      outputs.removeTask.drive(),
//      outputs.setAlertText.drive(alertLabel.rx.text),
      
//      outputs.showAlert.drive(showAlertBinder),
//      outputs.showAddTaskButton.drive(showAddTaskButtonBinder),
//      outputs.showRemovaAllButton.drive(showRemovaAllButtonBinder),
//      outputs.title.drive(titleLabel.rx.text)
    ]
      .forEach({ $0?.disposed(by: disposeBag) })

  }
  
  // MARK: - Binders
//  var changeBinder: Binder<Result<Void, Error>> {
//    return Binder(self, binding: { (vc, _) in
//      vc.collectionView.reloadData()
//    })
//  }
//
//  var hideAlertBinder: Binder<Void> {
//    return Binder(self, binding: { (vc, _) in
//      vc.alertView.isHidden = true
//    })
//  }
//
//  var hideCellBinder: Binder<IndexPath> {
//    return Binder(self, binding: { (vc, indexPath) in
//      if let cell = vc.collectionView.cellForItem(at: indexPath) as? TaskCell {
//        cell.hideSwipe(animated: true)
//      }
//    })
//  }
//
//  var showAlertBinder: Binder<Void> {
//    return Binder(self, binding: { (vc, _) in
//      vc.alertView.isHidden = false
//    })
//  }
//
//  var showAddTaskButtonBinder: Binder<Void> {
//    return Binder(self, binding: { (vc, _) in
//      vc.addButton.isHidden = false
//    })
//  }
//
//  var showRemovaAllButtonBinder: Binder<Void> {
//    return Binder(self, binding: { (vc, _) in
//      vc.removeAllButton.isHidden = false
//    })
//  }
//
//  var addTaskButtonIsHiddenBinder: Binder<Bool> {
//    return Binder(self, binding: { (vc, isHidden) in
//      vc.addButton.isHidden = isHidden
//    })
//  }
//
//  var removeAllDeletedTasksButtonIsHiddenBinder: Binder<Bool> {
//    return Binder(self, binding: { (vc, isHidden) in
//      vc.removeAllButton.isHidden = isHidden
//    })
//  }
  
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskListSection>(configureCell: { dataSource, collectionView, indexPath, item in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KindOfTaskListCell.reuseID, for: indexPath) as! KindOfTaskListCell
      cell.configure(with: item)
//      cell.delegate = self
//      cell.disposeBag = DisposeBag()
//      cell.repeatButton.rx.tap
//        .map{ _ -> IndexPath in indexPath }
//        .asDriver(onErrorJustReturn: nil)
//        .drive(self.repeatButtonBinder)
//        .disposed(by: cell.disposeBag)
      return cell
    })
  }
  
//  var repeatButtonBinder: Binder<IndexPath?> {
//    return Binder(self, binding: { (vc, indexPath) in
//      guard let indexPath = indexPath else { return }
//      self.viewModel.changeStatus(indexPath: indexPath, status: .InProgress, completed: nil)
//    })
//  }
  
}
