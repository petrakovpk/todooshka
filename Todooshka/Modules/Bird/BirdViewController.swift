//
//  BirdViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class BirdViewController: UIViewController {

  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>!
  
  // MARK: - Header UI Elemenets
  private let headerView = UIView()
  private let titleLabel = UILabel()
  private let dividerView = UIView()
  private let backButton = UIButton(type: .custom)
  
  // MARK: - Body UI Elemenets
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let typeLabel: UILabel = {
    let label = UILabel()
    label.text = "Эта птица будет появляться при выполнении задач с типом:"
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  private var collectionView: UICollectionView!
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.layer.cornerRadius = 15
    return textView
  }()
  
  private let priceLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    return label
  }()
  
  private let buyButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 15
    button.setTitle("Купить", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = UIColor(hexString: "ec55d4")
    return button
  }()
  
  private let isBoughtLabel: UILabel = {
    let label = UILabel()
    label.text = "Куплено!"
    label.textAlignment = .center
    return label
  }()
  
  // MARK: - MVVM
  public var viewModel: BirdViewModel!
  
  // MARK: - RX Elements
  private let disposeBag = DisposeBag()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    configureHeader()
    configureBody()
    configureDataSource()
    bindViewModel()
  }
  
  // MARK: - Configure
  func configureHeader() {
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
    titleLabel.text = "Добро пожаловать в магазин!"
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
    // collectionView
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubview(imageView)
    view.addSubview(typeLabel)
    view.addSubview(collectionView)
    view.addSubview(descriptionTextView)
    view.addSubview(priceLabel)
    view.addSubview(buyButton)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // imageView
    imageView.anchorCenterXToSuperview()
    imageView.anchor(top: headerView.bottomAnchor, topConstant: 16, widthConstant: 100, heightConstant: 130)
    
    // chooseTypeLabel
    typeLabel.anchor(top: imageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16)
    
    // collectionView
    collectionView.backgroundColor = UIColor.clear
    collectionView.clipsToBounds = false
    collectionView.isScrollEnabled = false
    collectionView.register(TypeSmallCollectionViewCell.self, forCellWithReuseIdentifier: TypeSmallCollectionViewCell.reuseID)
    collectionView.anchor(top: typeLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16.superAdjusted, leftConstant: 16, heightConstant: 60.superAdjusted )
    
    // descriptionTextView
    descriptionTextView.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 100)
    
    // priceLabel
    priceLabel.anchor(top: descriptionTextView.bottomAnchor, topConstant: 16)
    priceLabel.anchorCenterXToSuperview()
    
    // buyButton
    buyButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, leftConstant: 16, bottomConstant: 32, rightConstant: 16, heightConstant: 50)
    
    //birdIsBoughtLabel
   // isBoughtLabel.anchor(top: buyButton.topAnchor, left: buyButton.leftAnchor, bottom: buyButton.bottomAnchor, right: buyButton.rightAnchor)
  }
  
  //MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(70.superAdjusted), heightDimension: .absolute(70.superAdjusted ))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(70.superAdjusted), heightDimension: .estimated(70.superAdjusted))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
    
    let input = BirdViewModel.Input(
      // buttons
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      buyButtonClickTrigger: buyButton.rx.tap.asDriver(),
      // collectionView
      selection: collectionView.rx.itemSelected.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      // title
      outputs.title.drive(titleLabel.rx.text),
      // description
      outputs.description.drive(descriptionTextView.rx.text),
      // image
      outputs.image.drive(imageViewBinder),
      // collectionView
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.selection.drive(),
      // buttons
      outputs.backButtonClickHandler.drive(),
      outputs.buyButtonClickHandler.drive(),
      // buyButtonIsHidden
      outputs.buyButtonIsHidden.drive(buyButtonIsHidden),
      // price
      outputs.price.drive(priceLabel.rx.text)
    ]
      .forEach({$0.disposed(by: disposeBag)})
  }
  
  // MARK: - Binders
  var isBoughtLabelIsHidden: Binder<Bool> {
    return Binder(self, binding: { (vc, isHidden) in
      vc.isBoughtLabel.isHidden = isHidden
    })
  }
  
  var buyButtonIsHidden: Binder<Bool> {
    return Binder(self, binding: { (vc, isHidden) in
      vc.buyButton.isHidden = isHidden
    })
  }
  
  var imageViewBinder: Binder<UIImage?> {
    return Binder(self, binding: { (vc, image) in
      vc.imageView.image = image
    })
  }
  
  // MARK: - Configure DataSource
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>(
      configureCell: {(_, collectionView, indexPath, type) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeSmallCollectionViewCell.reuseID, for: indexPath) as! TypeSmallCollectionViewCell
        cell.configure(with: type, isSelected: type.birdUID == self.viewModel.bird.UID)
        return cell
      })
  }
  
}
