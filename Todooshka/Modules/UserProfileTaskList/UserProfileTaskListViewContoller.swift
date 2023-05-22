//
//  UserProfileTaskListViewContoller.swift
//  DragoDo
//
//  Created by Pavel Petakov on 01.05.2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class UserProfileTaskListViewContoller: UIViewController {
  public var viewModel: UserProfileTaskListViewModel!
  
  private let disposeBag = DisposeBag()
  
  private var isInitialized = false
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSection>!
  
  func configureUI() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    collectionView.register(TaskListCell.self, forCellWithReuseIdentifier: TaskListCell.reuseID)
    collectionView.register(TaskListReusableView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: TaskListReusableView.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.layer.masksToBounds = false
    collectionView.backgroundColor = .clear
        
    view.addSubviews([
      collectionView
    ])

    collectionView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      bottomConstant: 8,
      rightConstant: 16
    )
  }
  
  // MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 5, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 0, trailing: 0)
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(20))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)
    section.boundarySupplementaryItems = [header]
    return section
  }
  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = UserProfileTaskListViewModel.Input(
      selection: collectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.taskListSections.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.openTask.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  // MARK: - Configure Data Source
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSection>(configureCell: { dataSource, collectionView, indexPath, item in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskListCell.reuseID, for: indexPath) as! TaskListCell
      cell.configure(with: item)
      return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskListReusableView.reuseID, for: indexPath) as! TaskListReusableView 
      header.configure(text: dataSource[indexPath.section].header)
      return header
    })
  }
  
}

