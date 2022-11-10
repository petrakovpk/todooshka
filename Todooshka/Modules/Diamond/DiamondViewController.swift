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
    view.backgroundColor = Style.Views.GameCurrency.textViewBackground
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

  private let smallOfferBackground = TDDiamondPackageOfferView(type: .small)
  private let mediumOfferBackground = TDDiamondPackageOfferView(type: .medium)
  private let largeOfferBackground = TDDiamondPackageOfferView(type: .large)

  private let buyButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 15
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.Cerise
    return button
  }()

  // MARK: - Alert
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()

  private let alertWindowView: UIView = {
    let view = UIView()
    view.cornerRadius = 27
    view.backgroundColor = Style.App.background
    return view
  }()

  private let alertLabel: UILabel = {
    let label = UILabel(text: "Пока такой возможности нет :(")
    label.textColor = Style.App.text
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: min(17.adjustByWidth, 17.adjustByHeight), weight: .medium)
    return label
  }()

  private let alertOkButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Буду ждать!",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
    )
    let button = UIButton(type: .custom)
    button.backgroundColor = Style.Buttons.AlertRoseButton.Background
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    // titleLabel
    titleLabel.text = "Бриллиант"

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

  func configureAlert() {
    view.addSubview(alertBackgroundView)

    alertBackgroundView.addSubviews([
      alertWindowView,
      alertLabel,
      alertOkButton
    ])

    // alertView
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)

    // alertSubView
    alertWindowView.anchor(widthConstant: Sizes.Views.AlertDeleteView.width, heightConstant: Sizes.Views.AlertDeleteView.height)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()

    // alertLabel
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * Sizes.Views.AlertDeleteView.height / 4)

    // alertOkButton
    alertOkButton.anchor(widthConstant: Sizes.Buttons.AlertWillWaitButton.width, heightConstant: Sizes.Buttons.AlertWillWaitButton.height)
    alertOkButton.cornerRadius = Sizes.Buttons.AlertWillWaitButton.height / 2
    alertOkButton.anchorCenterXToSuperview()
    alertOkButton.anchorCenterYToSuperview(constant: 25)
  }

  // MARK: - Bind To
  func bindViewModel() {
    let input = DiamondViewModel.Input(
      alertOkButtonClickTrigger: alertOkButton.rx.tap.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      buyButtonClickTrigger: buyButton.rx.tap.asDriver(),
      smallOfferBackgroundClickTrigger: smallOfferBackground.rx.tapGesture().when(.recognized).map { _ in return () }.asDriver(onErrorJustReturn: ()),
      largeOfferBackgroundClickTrigger: largeOfferBackground.rx.tapGesture().when(.recognized).map { _ in return () }.asDriver(onErrorJustReturn: ()),
      mediumOfferBackgroundClickTrigger: mediumOfferBackground.rx.tapGesture().when(.recognized).map { _ in return () }.asDriver(onErrorJustReturn: ())
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.hideAlertTrigger.drive(hideAlertBinder),
      outputs.navigateBack.drive(),
      outputs.offerSelected.drive(offerSelectedBinder),
      outputs.sendOffer.drive(),
      outputs.showAlertTrigger.drive(showAlertBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }

  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertBackgroundView.isHidden = true
    })
  }

  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertBackgroundView.isHidden = false
    })
  }

  var offerSelectedBinder: Binder<DiamondPackageType> {
    return Binder(self, binding: { vc, diamondPackageType in
      switch diamondPackageType {
      case .small:
        vc.smallOfferBackground.isSelected = true
        vc.mediumOfferBackground.isSelected = false
        vc.largeOfferBackground.isSelected = false
        vc.buyButton.setTitle("Купить за 99 рублей!", for: .normal)
      case .medium:
        vc.smallOfferBackground.isSelected = false
        vc.mediumOfferBackground.isSelected = true
        vc.largeOfferBackground.isSelected = false
        vc.buyButton.setTitle("Купить за 149 рублей!", for: .normal)
      case .large:
        vc.smallOfferBackground.isSelected = false
        vc.mediumOfferBackground.isSelected = false
        vc.largeOfferBackground.isSelected = true
        vc.buyButton.setTitle("Купить за 249 рублей!", for: .normal)
      }
    })
  }
}
