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

class ShopViewController: UIViewController {
  
  // MARK: - Header UI Elemenets
  private let headerView = UIView()
  private let titleLabel = UILabel()
  private let dividerView = UIView()
  private let backButton = UIButton(type: .custom)
  
  // MARK: - UI elements
  private var collectionView: UICollectionView!
  
  // MARK: - MVVM
  public var viewModel: ShopViewModel!
  
  // MARK: - RX Elements
  private let disposeBag = DisposeBag()
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<ShopSectionModel>!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    configureHeader()
    configureBody()
    configureDataSource()
    bindViewModel()
  }
  
  func configureHeader() {
    
    // adding
    view.addSubview(headerView)
    headerView.addSubview(titleLabel)
    headerView.addSubview(backButton)
    headerView.addSubview(dividerView)
    
    // headerView
    headerView.backgroundColor = UIColor(named: "navigationHeaderViewBackgroundColor")
    headerView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      heightConstant: 96)
    
    // titleLabel
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.text = "Фабрика птиц"
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)
    
    // backButton
    backButton.imageView?.tintColor = Theme.App.text
    backButton.setImage(
      UIImage(named: "arrow-left")?.template,
      for: .normal)
    backButton.anchor(
      top: view.safeAreaLayoutGuide.topAnchor,
      left: headerView.leftAnchor,
      bottom: headerView.bottomAnchor,
      widthConstant: UIScreen.main.bounds.width / 6)
    
    // dividerView
    dividerView.backgroundColor = UIColor(named: "navigationDividerViewBackgroundColor")
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
  }
  
  func configureBody() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubview(collectionView)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // collectionView
    collectionView.register(ShopCollectionViewCell.self, forCellWithReuseIdentifier: ShopCollectionViewCell.reuseID)
    collectionView.register(ShopCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShopCollectionViewHeader.reuseID)
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
      rightConstant: 16)
  }
  
  func configureDataSource() {
    dataSource = RxCollectionViewSectionedAnimatedDataSource<ShopSectionModel>(configureCell: { _, collectionView, indexPath, item in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopCollectionViewCell.reuseID, for: indexPath) as! ShopCollectionViewCell
      cell.configure(bird: item)
      return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ShopCollectionViewHeader.reuseID, for: indexPath) as! ShopCollectionViewHeader
      section.label.text = dataSource[indexPath.section].header
      return section
    })
  }
  
  //MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(130), heightDimension: .absolute(160))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    
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
      output.backButtonClickHandler.drive(),
      output.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      output.itemSelected.drive()
    ]
      .forEach({$0.disposed(by: disposeBag)})
  }
 
}
