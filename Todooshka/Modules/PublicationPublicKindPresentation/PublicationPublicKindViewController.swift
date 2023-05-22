//
//  PublicationPublicKindViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 19.05.2023.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift
import AnyImageKit

class PublicationPublicKindViewController: UIViewController {
  public var viewModel: PublicationPublicKindViewModel!
  
  private let disposeBag = DisposeBag()

  private let kindLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    label.text = "Выберите тип:"
    return label
  }()

  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<PublicKindSection>!

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  func configureUI() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    collectionView.backgroundColor = UIColor.clear
    collectionView.clipsToBounds = false
    collectionView.isScrollEnabled = false
    collectionView.register(PublicationPublicKindCell.self, forCellWithReuseIdentifier: PublicationPublicKindCell.reuseID)
    
    view.backgroundColor = Style.App.background
    
    view.addSubviews([
      kindLabel,
      collectionView
    ])

    kindLabel.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    collectionView.anchor(
      top: kindLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      heightConstant: Sizes.Views.KindsOfTaskCollectionView.height
    )
  }
  
  func bindViewModel() {
    let input = PublicationPublicKindViewModel.Input(
      selection: collectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.publicKindSections.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.publicationUpdatePublicKind.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  // MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .absolute(Sizes.Cells.KindCell.width),
      heightDimension: .absolute(Sizes.Cells.KindCell.height))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .estimated(Sizes.Cells.KindCell.width),
      heightDimension: .estimated(Sizes.Cells.KindCell.height))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
  
  func configureDataSource() {
    collectionView.dataSource = nil
    
    dataSource = RxCollectionViewSectionedAnimatedDataSource<PublicKindSection>(
      configureCell: {_, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublicationPublicKindCell.reuseID, for: indexPath) as! PublicationPublicKindCell
        cell.configure(with: item)
        return cell
      })
  }
}

