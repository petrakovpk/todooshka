//
//  DiamondViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 20.06.2022.
//

import UIKit
import RxSwift
import RxCocoa

class DiamondViewController: TDViewController {
  
  // MARK: - Const
  private let offerWidth = (UIScreen.main.bounds.width - 16 * 4 ) / 3 
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - MVVM
  public var viewModel: DiamondViewModel!
  
  // MARK: - UI Elemenets
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(named: "diamond")
    return imageView
  }()
  
  private let descriptionBackgroundView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 15
    view.backgroundColor = Theme.GameCurrency.textViewBackground
    return view
  }()
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.layer.cornerRadius = 15
    textView.backgroundColor = .clear
    textView.textAlignment = .center
    textView.text = "Это бриллиант. Его можно приобрести только за деньги. За бриллианты можно приобрести особые типы птиц."
    return textView
  }()
  
  private let smallOfferBackground = TDDiamondPackageOfferView(type: .Small)
  private let mediumOfferBackground = TDDiamondPackageOfferView(type: .Medium)
  private let largeOfferBackground = TDDiamondPackageOfferView(type: .Large)
  
  private let buyButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 15
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.Cerise
    return button
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  // MARK: - Configure UI
  func configureUI() {
    // titleLabel
    titleLabel.text = "Бриллианты"
    
    // adding
    view.addSubviews([
      imageView,
      descriptionBackgroundView,
      smallOfferBackground,
      mediumOfferBackground,
      largeOfferBackground,
      buyButton
    ])
    
    // sub addibg
    descriptionBackgroundView.addSubview(descriptionTextView)

    // imageView
    imageView.anchorCenterXToSuperview()
    imageView.anchor(top: headerView.bottomAnchor, topConstant: 16, widthConstant: 100, heightConstant: 130)
    
    // descriptionBackgroundView
    descriptionBackgroundView.anchor(top: imageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 32, leftConstant: 16, rightConstant: 16, heightConstant: 150)
    
    // descriptionTextView
    descriptionTextView.anchorCenterYToSuperview()
    descriptionTextView.anchor(left: descriptionBackgroundView.leftAnchor, right: descriptionBackgroundView.rightAnchor, leftConstant: 16, rightConstant: 16)
    
    // secondOfferBackground
    mediumOfferBackground.anchorCenterXToSuperview()
    mediumOfferBackground.anchor(top: descriptionBackgroundView.bottomAnchor, topConstant: 16, widthConstant: offerWidth, heightConstant: offerWidth * 1.5)
    
    // firstOfferBackground
    smallOfferBackground.anchor(top: mediumOfferBackground.topAnchor, bottom: mediumOfferBackground.bottomAnchor, right: mediumOfferBackground.leftAnchor, rightConstant: 16, widthConstant: offerWidth)
    
    // thirdOfferBackground
    largeOfferBackground.anchor(top: mediumOfferBackground.topAnchor, left: mediumOfferBackground.rightAnchor, bottom: mediumOfferBackground.bottomAnchor, leftConstant: 16, widthConstant: offerWidth)
    
    // buyButton
    buyButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, leftConstant: 16, bottomConstant: 32, rightConstant: 16, heightConstant: 50)
  }
  
  // MARK: - Bind To
  func bindViewModel() {
    
    let input = DiamondViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      smallOfferBackgroundClickTrigger: smallOfferBackground.rx.tapGesture().when(.recognized).map{ _ in return ()}.asDriver(onErrorJustReturn: ()),
      mediumOfferBackgroundClickTrigger: mediumOfferBackground.rx.tapGesture().when(.recognized).map{ _ in return ()}.asDriver(onErrorJustReturn: ()),
      largeOfferBackgroundClickTrigger: largeOfferBackground.rx.tapGesture().when(.recognized).map{ _ in return () }.asDriver(onErrorJustReturn: ()),
      buyButtonClickTrigger: buyButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.backButtonClickHandler.drive(),
      outputs.offerSelected.drive(offerSelectedBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  var offerSelectedBinder: Binder<DiamondPackageType> {
    return Binder(self, binding: { (vc, diamondPackageType) in
      switch diamondPackageType {
      case .Small:
        vc.smallOfferBackground.isSelected = true
        vc.mediumOfferBackground.isSelected = false
        vc.largeOfferBackground.isSelected = false
        vc.buyButton.setTitle("Купить за 99 рублей!", for: .normal)
      case .Medium:
        vc.smallOfferBackground.isSelected = false
        vc.mediumOfferBackground.isSelected = true
        vc.largeOfferBackground.isSelected = false
        vc.buyButton.setTitle("Купить за 149 рублей!", for: .normal)
      case .Large:
        vc.smallOfferBackground.isSelected = false
        vc.mediumOfferBackground.isSelected = false
        vc.largeOfferBackground.isSelected = true
        vc.buyButton.setTitle("Купить за 249 рублей!", for: .normal)
      }
    })
  }
  
}
