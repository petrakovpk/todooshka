//
//  FeatherViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 20.06.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FeatherViewController: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - MVVM
  public var viewModel: FeatherViewModel!
  
  // MARK: - UI Elemenets
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(named: "feather")
    return imageView
  }()
  
  private let descriptionBackgroundView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 15
    view.backgroundColor = Theme.Views.GameCurrency.textViewBackground
    return view
  }()
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.layer.cornerRadius = 15
    textView.backgroundColor = .clear
    textView.textAlignment = .center
    textView.text = "Это перышко. Его можно получить, выполняя ежедневные задания, которые ты сам себе ставишь. За день можно получить не более 7 перышек. Перышки можно потратить на покупку обычных птиц."
    return textView
  }()
  
  private let label: UILabel = {
    let label = UILabel()
    label.text = "Задачи, за которые вы получили перышки:"
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSection>!

  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  // MARK: - Configure UI
  func configureUI() {
    
    //  header
    titleLabel.text = "Перышко"
    
    // collectionView
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubview(imageView)
    view.addSubview(label)
    view.addSubview(collectionView)
    view.addSubview(descriptionBackgroundView)
    descriptionBackgroundView.addSubview(descriptionTextView)
    
    // imageView
    imageView.anchorCenterXToSuperview()
    imageView.anchor(top: headerView.bottomAnchor, topConstant: 16, widthConstant: 100, heightConstant: 130)
    
    // descriptionBackgroundView
    descriptionBackgroundView.anchor(top: imageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 32, leftConstant: 16, rightConstant: 16, heightConstant: 150)
    
    // descriptionTextView
    descriptionTextView.anchor(left: descriptionBackgroundView.leftAnchor, right: descriptionBackgroundView.rightAnchor, leftConstant: 16, rightConstant: 16)
    descriptionTextView.anchorCenterYToSuperview()
    
    // label
    label.anchor(top: descriptionBackgroundView.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16)
    label.layer.zPosition = 10
    
    // collectionView
    collectionView.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.reuseID)
    collectionView.register(TaskReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskReusableView.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .clear
    collectionView.clipsToBounds = false
    collectionView.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
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
    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    section.boundarySupplementaryItems = [header]
    return section
  }
  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    
    let input = FeatherViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.navigateBack.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  // MARK: - Configure DataSource
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSection>(configureCell: { dataSource, collectionView, indexPath, item in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.reuseID, for: indexPath) as! TaskCell
      cell.configure(with: dataSource[indexPath.section].mode)
      cell.configure(with: item.task)
      cell.configure(with: item.kindOfTask)
      return cell
    }, configureSupplementaryView: { dataSource , collectionView, kind, indexPath in
      let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskReusableView.reuseID, for: indexPath) as! TaskReusableView
      section.configure(text: dataSource[indexPath.section].header)
      return section
    })
  }
  
}
