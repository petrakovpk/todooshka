//
//  ProfileViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.01.2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture

class ProfileViewController: TDViewController {
  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: ProfileViewModel!
  
  // MARK: - UI Elements
  private let authorImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 5
    imageView.backgroundColor = .black.withAlphaComponent(0.2)
    return imageView
  }()
 
  private let dividerView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.2)
    return view
  }()
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskSection>!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    // header
    titleLabel.text = "Conor"
    
    // collection view
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    collectionView.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.reuseID)
    collectionView.register(TaskWithImageCell.self, forCellWithReuseIdentifier: TaskWithImageCell.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .clear
    
    // adding
    view.addSubviews([
      authorImageView,
      dividerView,
      collectionView
    ])
    
    // authorImageView
    authorImageView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 100,
      heightConstant: 100
    )
   
    // dividerView
    dividerView.anchor(
      top: authorImageView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      heightConstant: 0.5
    )
    
    // collectionView
    collectionView.anchor(
      top: dividerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
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
  

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = ProfileViewModel.Input()

    let outputs = viewModel.transform(input: input)

//    [
//
//    ]
//      .forEach { $0.disposed(by: disposeBag) }
  }
  
  // MARK: - Color CollectionView
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskSection>(
      configureCell: {dataSource, collectionView, indexPath, item in
        switch item.type {
        case .text:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TaskWithImageCell.reuseID,
            for: indexPath
          ) as? TaskCell else { return UICollectionViewCell() }
       //   cell.configure(mode: dataSource[indexPath.section].mode, task: item.task, kindOfTask: item.kindOfTask)
          return cell
        case .textAndImage:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TaskWithImageCell.reuseID,
            for: indexPath
          ) as? TaskWithImageCell else { return UICollectionViewCell() }
          cell.configure(with: item.task)
          return cell
        }
        return UICollectionViewCell()
      })
  }
  
}


