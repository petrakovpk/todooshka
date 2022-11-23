//
//  MarketplaceViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MarketplaceViewController: TDViewController {
  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: MarketplaceViewModel!
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<ThemeSection>!
  
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
    addButton.isHidden = false
    headerView.layer.zPosition = 2
    titleLabel.text = "Чем научимся сегодня?"
    
    // collectionView
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubviews([
      collectionView,
    ])
    

    // collectionView
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .clear

    collectionView.register(
      ThemePlusButtonCell.self,
      forCellWithReuseIdentifier: ThemePlusButtonCell.reuseID)
    collectionView.register(
      ThemeCell.self,
      forCellWithReuseIdentifier: ThemeCell.reuseID)
    collectionView.register(
      ThemeHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: ThemeHeader.reuseID)
    collectionView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16)
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = MarketplaceViewModel.Input(
      addThemeButtonClickTrigger: addButton.rx.tap.asDriver(),
      selection: collectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.addTheme.drive(),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.openTheme.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }

  // MARK: - Configure Data Source
  private func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<ThemeSection>(
      configureCell: { _, collectionView, indexPath, item in
        switch item {
        case .theme(let theme):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ThemeCell.reuseID,
            for: indexPath
          ) as? ThemeCell else { return UICollectionViewCell() }
          cell.configure(with: theme)
          return cell
        }
      }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: ThemeHeader.reuseID,
          for: indexPath
        ) as? ThemeHeader else { return UICollectionReusableView() }
        header.configure(with: dataSource[indexPath.section])
        return header
      })
  }

  // MARK: - Setup CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }

  private func section() -> NSCollectionLayoutSection {
    // item
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .absolute(Sizes.Cells.ThemeCell.width),
      heightDimension: .absolute(Sizes.Cells.ThemeCell.height))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    // group
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .estimated(Sizes.Cells.ThemeCell.width),
      heightDimension: .estimated(Sizes.Cells.ThemeCell.height))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .fixed(5.0)
    // header
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top )
    // section
    let section = NSCollectionLayoutSection(group: group)
    section.boundarySupplementaryItems = [header]
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 5, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
}
