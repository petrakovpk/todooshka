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

  // MARK: - Properties
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

    // settings
    refreshButton.isHidden = false
    backButton.isHidden = false

    // collectionView
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())

    // adding
    view.addSubviews([
      collectionView
    ])

    //  header
    titleLabel.text = "Что будем делать?"

    // collectionView
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .clear
    collectionView.layer.masksToBounds = false
    collectionView.register(ThemeCell.self, forCellWithReuseIdentifier: ThemeCell.reuseID)
    collectionView.anchor(
      top: view.safeAreaLayoutGuide.topAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor
    )
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {

    let input = MarketplaceViewModel.Input(
      selection: collectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource))
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }

  // MARK: - Configure Data Source
  private func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<ThemeSection>(
      configureCell: { dataSource, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: ThemeCell.reuseID,
          for: indexPath
        ) as? ThemeCell else { return UICollectionViewCell() }
        cell.configure(with: dataSource[indexPath.section].items[indexPath.item].theme)
        return cell
      })
  }

  // MARK: - Setup CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }

  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(Sizes.Cells.ThemeCell.width), heightDimension: .estimated(Sizes.Cells.ThemeCell.height))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 5, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(Sizes.Cells.ThemeCell.width), heightDimension: .estimated(Sizes.Cells.ThemeCell.height))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 0, trailing: 0)
    return section
  }

}
