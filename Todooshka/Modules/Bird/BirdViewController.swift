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

class BirdViewController: TDViewController {
  
  // MARK: - Body UI Elemenets
  private let birdImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let changeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Изменить", for: .normal)
    button.setTitleColor(Theme.App.text, for: .normal)
    button.cornerRadius = 5
    button.backgroundColor = .systemGray.withAlphaComponent(0.3)
    return button
  }()
  
  private let kindOfTaskImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    imageView.image = KindOfTask.Standart.Business.icon.image.template
    imageView.tintColor = Palette.SingleColors.SantasGray
    return imageView
  }()
  
  private let typeLabel: UILabel = {
    let label = UILabel()
    label.text = "Эта птица для типов ниже:"
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskForBirdSection>!
  
  private let descriptionBackgroundView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 15
    view.layer.borderWidth = 1.0
    view.layer.borderColor = Theme.App.text?.cgColor
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
    label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
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
  
  private let buyLabel: UILabel = {
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
    super.viewDidLoad()
    configureBody()
    configureDataSource()
    bindViewModel()
  }
  
  // MARK: - Configure
  
  func configureBody() {
    
    // settings
    titleLabel.text = "Добро пожаловать в магазин!"
    
    // collectionView
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubviews([
      alertBuyView,
      birdImageView,
      buyButton,
      buyLabel,
      changeButton,
      collectionView,
      descriptionBackgroundView,
      kindOfTaskImageView,
      priceBackgroundView,
      typeLabel
    ])
    
    priceBackgroundView.addSubview(priceImageView)
    priceBackgroundView.addSubview(priceLabel)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // buyAlertView
    alertBuyView.isHidden = true
    alertBuyView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    // imageView
    birdImageView.anchorCenterXToSuperview()
    birdImageView.anchor(top: headerView.bottomAnchor, topConstant: 16, widthConstant: 200, heightConstant: 260)
    
    // kindOfTaskImageView
    kindOfTaskImageView.anchor(top: birdImageView.topAnchor, right: birdImageView.leftAnchor, topConstant: 8, rightConstant: 8, widthConstant: 40, heightConstant: 40)
    
    // priceBackgroundView
    priceBackgroundView.anchor(top: birdImageView.topAnchor, left: birdImageView.rightAnchor, topConstant: 8, leftConstant: 8, widthConstant: 40, heightConstant: 40)
    
    // priceImagView
    priceImageView.anchorCenterYToSuperview()
    priceImageView.anchor(right: priceBackgroundView.rightAnchor, widthConstant: 20, heightConstant: 40)
    
    // priceLabel
    priceLabel.anchorCenterYToSuperview()
    priceLabel.anchor(right: priceImageView.leftAnchor, topConstant: 8, rightConstant: 8)

    // typeLabel
    typeLabel.anchor(top: birdImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 32, leftConstant: 16, rightConstant: 16, heightConstant: 30)
    
    // changeButton
    changeButton.anchor(top: birdImageView.bottomAnchor, right: view.rightAnchor, topConstant: 32, rightConstant: 16, widthConstant: 100, heightConstant: 30)
    
    // collectionView
    collectionView.backgroundColor = UIColor.clear
    collectionView.clipsToBounds = false
    collectionView.register(KindOfTaskForBirdCell.self, forCellWithReuseIdentifier: KindOfTaskForBirdCell.reuseID)
    collectionView.anchor(top: typeLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, heightConstant: 60)
    
    // buyButton
    buyButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, leftConstant: 16, bottomConstant: 32, rightConstant: 16, heightConstant: 50)
    
    // isBoughtLabel
    buyLabel.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, leftConstant: 16, bottomConstant: 32, rightConstant: 16, heightConstant: 50)
    
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
      alertBuyButtonClick: alertBuyView.buyButton.rx.tap.asDriver(),
      alertCancelButtonClick: alertBuyView.cancelButton.rx.tap.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      buyButtonClickTrigger: buyButton.rx.tap.asDriver(),
      selection: collectionView.rx.itemSelected.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.addKindOfTask.drive(),
      outputs.birdImageView.drive(birdImageView.rx.image),
      outputs.kindOfTaskImageView.drive(kindOfTaskImageView.rx.image),
//      outputs.buyAlertViewIsHidden: buyAlertViewIsHidden,
//      outputs.buyButtonIsEnabled: buyButtonIsEnabled,
      outputs.buyButtonIsHidden.drive(buyButton.rx.isHidden),
//      outputs.eggImageView: eggImageView,
      outputs.buyLabelIsHidden.drive(buyLabel.rx.isHidden),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.description.drive(descriptionTextView.rx.text),
//      outputs.labelText: labelText,
      outputs.navigateBack.drive(),
      outputs.price.drive(priceLabel.rx.text),
//      outputs.selectedKindOfTask: selectedKindOfTask,
//      outputs.title: title
//      outputs.birdImageView.drive(alertBuyView.birdImageView.rx.image),
//      outputs.buyButtonIsHidden.drive(buyButton.rx.isHidden),
//     // outputs.buy.drive(),
//      outputs.buyAlertViewIsHidden.drive(alertBuyView.rx.isHidden),
//      outputs.buyButtonIsEnabled.drive(alertBuyView.buyButton.rx.isEnabled),
//      outputs.eggImageView.drive(alertBuyView.eggImageView.rx.image),
//    //
//      outputs.description.drive(descriptionTextView.rx.text),
//      outputs.isBoughtLabel.drive(isBoughtLabel.rx.isHidden),
//   //   outputs.image.drive(imageView.rx.image),
//      outputs.labelText.drive(alertBuyView.label.rx.text),
//      outputs.navigateBack.drive(),
//      outputs.price.drive(priceLabel.rx.text),
//      outputs.selection.drive(),
      outputs.title.drive(titleLabel.rx.text),
    ]
      .forEach({$0.disposed(by: disposeBag)})
  }
    
  // MARK: - Configure DataSource
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskForBirdSection>(
      configureCell: {(_, collectionView, indexPath, item) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KindOfTaskForBirdCell.reuseID, for: indexPath) as! KindOfTaskForBirdCell
        item.isPlusButton ? cell.configureAsPlusButton() : cell.configure(with: item)
        return cell
      })
  }
  
}
