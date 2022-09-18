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
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TypeSmallCollectionViewCellSectionModel>!
  
  private let descriptionBackgroundView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 15
    view.layer.borderWidth = 1.0
    view.layer.borderColor = Palette.SingleColors.BlueRibbon.cgColor
    return view
  }()

  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.layer.cornerRadius = 15
    textView.backgroundColor = .clear
    return textView
  }()
  
  private let priceBackgroundView: UIView = {
    let view = UIView()

    return view
  }()
  
  private let priceLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    label.textColor = UIColor(hexString: "ec55d4")
    return label
  }()
  
  private let priceImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "feather")
    return imageView
  }()
  
  private let buyButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 15
    button.setTitle("Открыть!", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.Cerise
    return button
  }()
  
  private let isBoughtLabel: UILabel = {
    let label = UILabel()
    label.text = "Птица открыта!"
    label.textAlignment = .center
    return label
  }()
  
  private let alertBuyView = AlertBuyView()
  
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
      
    // adding
    view.addSubview(headerView)
    headerView.addSubview(titleLabel)
    headerView.addSubview(backButton)
    headerView.addSubview(dividerView)
    headerView.addSubview(priceBackgroundView)
    priceBackgroundView.addSubview(priceImageView)
    priceBackgroundView.addSubview(priceLabel)
    
    // headerView
    headerView.backgroundColor = UIColor(named: "navigationHeaderViewBackgroundColor")
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: 96)
    
    // titleLabel
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.text = "Добро пожаловать в магазин!"
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)
    
    // backButton
    backButton.imageView?.tintColor = Theme.App.text
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // dividerView
    dividerView.backgroundColor = UIColor(named: "navigationDividerViewBackgroundColor")
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    // priceBackgroundView
    priceBackgroundView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, rightConstant: 16, widthConstant: 40)
    
    // priceImagView
    priceImageView.anchorCenterYToSuperview()
    priceImageView.anchor(right: headerView.rightAnchor, rightConstant: 16, widthConstant: 15, heightConstant: 30)
    
    // priceLabel
    priceLabel.anchorCenterYToSuperview()
    priceLabel.anchor(right: priceImageView.leftAnchor, topConstant: 8, rightConstant: 8)
  }
  
  func configureBody() {
    
    // collectionView
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubviews([
      imageView,
      typeLabel,
      collectionView,
      descriptionBackgroundView,
      buyButton,
      isBoughtLabel,
      alertBuyView
    ])

    // view
    view.backgroundColor = Theme.App.background
    
    // buyAlertView
    alertBuyView.isHidden = true
    alertBuyView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    // imageView
    imageView.anchorCenterXToSuperview()
    imageView.anchor(top: headerView.bottomAnchor, topConstant: 16, widthConstant: 200, heightConstant: 260)
    
    // chooseTypeLabel
    typeLabel.anchor(top: imageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 32, leftConstant: 16, rightConstant: 16)
    
    // collectionView
    collectionView.backgroundColor = UIColor.clear
    collectionView.clipsToBounds = false
    collectionView.isScrollEnabled = false
    collectionView.register(TypeSmallCollectionViewCell.self, forCellWithReuseIdentifier: TypeSmallCollectionViewCell.reuseID)
    collectionView.anchor(top: typeLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16.superAdjusted, leftConstant: 16, heightConstant: 60.superAdjusted )
    
    // buyButton
    buyButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, leftConstant: 16, bottomConstant: 32, rightConstant: 16, heightConstant: 50)
    
    // isBoughtLabel
    isBoughtLabel.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, leftConstant: 16, bottomConstant: 32, rightConstant: 16, heightConstant: 50)
    
    // descriptionBackgroundView
    descriptionBackgroundView.addSubview(descriptionTextView)
    descriptionBackgroundView.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, bottom: buyButton.topAnchor, right: view.rightAnchor, topConstant: 32, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
    
    // descriptionTextView
    descriptionTextView.anchorCenterXToSuperview()
    descriptionTextView.anchorCenterYToSuperview()
    
  }
  
  //MARK: - CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(76.superAdjusted), heightDimension: .absolute(76.superAdjusted ))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10)
    let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(76.superAdjusted), heightDimension: .estimated(76.superAdjusted))
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
      alertCancelButtonClick: alertBuyView.cancelButton.rx.tap.asDriver(),
      alertBuyButtonClick: alertBuyView.buyButton.rx.tap.asDriver(),
      // collectionView
      selection: collectionView.rx.itemSelected.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      // title
      outputs.title.drive(titleLabel.rx.text),
      // image
      outputs.image.drive(imageView.rx.image),
      // description
      outputs.description.drive(descriptionTextView.rx.text),
      // collectionView
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      // price
      outputs.price.drive(priceLabel.rx.text),
      // buyButtonIsHidden
      outputs.buyButtonIsHidden.drive(buyButton.rx.isHidden),
      // isBoughtLabel
      outputs.isBoughtLabel.drive(isBoughtLabel.rx.isHidden),
      // buyAlertViewIsHidden
      outputs.buyAlertViewIsHidden.drive(alertBuyView.rx.isHidden),
      // eggImageView
      outputs.eggImageView.drive(alertBuyView.eggImageView.rx.image),
      // birdImageView
      outputs.birdImageView.drive(alertBuyView.birdImageView.rx.image),
      // buyButtonIsEnabled
      outputs.buyButtonIsEnabled.drive(alertBuyView.buyButton.rx.isEnabled),
      // labelText
      outputs.labelText.drive(alertBuyView.label.rx.text),
      // back
      outputs.back.drive(),
      // selection
      outputs.selection.drive(),
      // buy
      outputs.buy.drive()
    ]
      .forEach({$0.disposed(by: disposeBag)})
  }
    
  // MARK: - Configure DataSource
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TypeSmallCollectionViewCellSectionModel>(
      configureCell: {(_, collectionView, indexPath, item) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeSmallCollectionViewCell.reuseID, for: indexPath) as! TypeSmallCollectionViewCell
        cell.configure(with: item.kindOfTask, isSelected: item.isSelected, isEnabled: item.isEnabled)
        return cell
      })
  }
  
}
