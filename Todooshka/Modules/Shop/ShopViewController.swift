//
//  ShopViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 01.02.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ShopViewController: TDViewController {

  // MARK: - UI elements
  private var collectionView: UICollectionView!

  // MARK: - MVVM
  public var viewModel: ShopViewModel!

  // MARK: - RX Elements
  private let disposeBag = DisposeBag()
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<ShopSection>!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureBody()
    configureDataSource()
    bindViewModel()
  }

  func configureBody() {
    // titleLabel
    titleLabel.text = "Фабрика птиц"

    // collectionView
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())

    // adding
    view.addSubview(collectionView)

    // view
    view.backgroundColor = Style.App.background

    // collectionView
    collectionView.register(ShopCollectionViewCell.self, forCellWithReuseIdentifier: ShopCollectionViewCell.reuseID)
    collectionView.register(
      ShopCollectionViewHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: ShopCollectionViewHeader.reuseID
    )
    collectionView.isScrollEnabled = true
    collectionView.backgroundColor = UIColor.clear
    collectionView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
  }

  func configureDataSource() {
    dataSource = RxCollectionViewSectionedAnimatedDataSource<ShopSection>(configureCell: { _, collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: ShopCollectionViewCell.reuseID,
        for: indexPath
      ) as? ShopCollectionViewCell else { return UICollectionViewCell() }
      cell.configure(bird: item)
      return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      guard let section = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: ShopCollectionViewHeader.reuseID,
        for: indexPath
      ) as? ShopCollectionViewHeader else { return UICollectionReusableView() }
      section.label.text = dataSource[indexPath.section].header
      return section
    })
  }

  // MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }

  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(130), heightDimension: .absolute(160))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 12, leading: 0, bottom: 0, trailing: 10)

    let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(130), heightDimension: .estimated(160))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(25.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 16, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    section.boundarySupplementaryItems = [header]
    return section
  }

  // MARK: - Bind View Model
  func bindViewModel() {
    let input = ShopViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      selection: collectionView.rx.itemSelected.asDriver()
    )

    let output = viewModel.transform(input: input)

    [
      output.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      output.navigateBack.drive(),
      output.show.drive()
    ]
      .forEach({$0.disposed(by: disposeBag)})
  }

}
