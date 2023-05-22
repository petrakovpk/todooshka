//
//  UserProfilePublicationViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 01.05.2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class UserProfilePublicationsViewController: UIViewController {
  public var viewModel: UserProfilePublicationsViewModel!
  
  private let disposeBag = DisposeBag()
  
  private var isInitialized = false
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<UserProfilePublicationSection>!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if !isInitialized {
      configureUI()
      configureDataSource()
      bindViewModel()
      // Выполните здесь операции, которые обычно выполняются в viewDidLoad
      isInitialized = true
    }
  }
  
  func configureUI() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    collectionView.register(
      UserProfilePublicationCell.self,
      forCellWithReuseIdentifier: UserProfilePublicationCell.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = Style.App.background

    view.addSubviews([
      collectionView
    ])
    
    
    collectionView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.bottomAnchor,
      right: view.rightAnchor
    )
  }
  
  // MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0/3.0),
      heightDimension: .absolute(Sizes.Cells.UserProfilePublicationCell.height))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(Sizes.Cells.UserProfilePublicationCell.height))
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item, item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    return section
  }

  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = UserProfilePublicationsViewModel.Input(
      selection: collectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.openPublication.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  // MARK: - Configure Data Source
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<UserProfilePublicationSection>(
      configureCell: {_, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfilePublicationCell.reuseID, for: indexPath) as! UserProfilePublicationCell
        cell.configure(with: item)
        cell.contentView.backgroundColor = UIColor.random.withAlphaComponent(0.2)
        return cell
      })
  }
  
}
