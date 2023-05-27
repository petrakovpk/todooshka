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
import RxGesture

class MarketplaceViewController: TDViewController {
  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: MarketplaceViewModel!
  
  // MARK: - UI Elements
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<MarketplaceQuestSection>!
  
  private let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.backgroundColor = Style.App.background
    searchBar.placeholder = "Дела, люди"
    searchBar.barTintColor = Style.App.background
    searchBar.borderWidth = 0.0
    searchBar.backgroundImage = UIImage()
    searchBar.searchTextField.backgroundColor = Style.TextFields.AuthTextField.Background
    return searchBar
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    headerView.layer.zPosition = 2
    titleLabel.text = "Задания"
    
    hideKeyboardWhenTappedAround()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .clear
    collectionView.register(MarketplaceQuestCell.self, forCellWithReuseIdentifier: MarketplaceQuestCell.reuseID)
    collectionView.register(MarketplaceQuestHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MarketplaceQuestHeader.reuseID)
    
    view.addSubviews([
      searchBar,
      collectionView
    ])

    searchBar.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      heightConstant: 40
    )

    collectionView.anchor(
      top: searchBar.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      bottomConstant: 8,
      rightConstant: 16)
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = MarketplaceViewModel.Input(
      // search
      searchBarClickTrigger: searchBar.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      // create
      createQuestButtonClickTrigger: addButton.rx.tap.asDriver(),
      selection: collectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)
    
    [
      // auth
    
      outputs.navigateToQuest.drive(),
      outputs.navigateToSearch.drive(),
      // marketplace
      outputs.marketplaceQuestSections.drive(collectionView.rx.items(dataSource: dataSource)),
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }

  // MARK: - Configure Data Source
  private func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<MarketplaceQuestSection>(
      configureCell: { _, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MarketplaceQuestCell.reuseID, for: indexPath) as! MarketplaceQuestCell
        cell.configure(with: item)
        return cell
      }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MarketplaceQuestHeader.reuseID, for: indexPath) as! MarketplaceQuestHeader
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
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .absolute(Sizes.Cells.ThemeCell.width),
      heightDimension: .absolute(Sizes.Cells.ThemeCell.height))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .estimated(Sizes.Cells.ThemeCell.width),
      heightDimension: .estimated(Sizes.Cells.ThemeCell.height))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .fixed(5.0)
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top )
    let section = NSCollectionLayoutSection(group: group)
    section.boundarySupplementaryItems = [header]
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 5, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
}
