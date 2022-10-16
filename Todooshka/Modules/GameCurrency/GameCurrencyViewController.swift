//
//  ScoreViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.02.2022.
//

import UIKit
import RxSwift
import RxCocoa

class ScoreViewController: UIViewController {
  
  // MARK: - Header UI Elemenets
  private let headerView = UIView()
  private let titleLabel = UILabel()
  private let backButton = UIButton(type: .custom)
  private let dividerView = UIView()
  
  // MARK: - Body UI Elemenets
  private let featherImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "feather")?
      .withAlignmentRectInsets(UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20))
    return imageView
  }()
  
  private let diamondImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "diamond")?
      .withAlignmentRectInsets(UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20))
    return imageView
  }()
  
  private let featherDescriptionTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 15
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.backgroundColor = Theme.Views.GameCurrency.textViewBackground
    textView.textAlignment = .center
    textView.text = "Перышко. Зарабатываются за выполнение задач. Ежедневно можно получить не более 7 перышек.  Перышки можно потратить их на покупку обычных птиц."
    return textView
  }()
  
  private let diamondDescriptionTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 15
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.backgroundColor = Theme.Views.GameCurrency.textViewBackground
    textView.textAlignment = .center
    textView.text = "Бриллиант. Приобретаются за деньги. Бриллианты можно потратить на покупку редких птиц."
    return textView
  }()
  
  private let smallPackageButton: UIButton = {
    let button = UIButton()
    button.setTitle("5", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .systemRed.withAlphaComponent(0.2)
    button.layer.cornerRadius = 15
    return button
  }()
  
  private let mediumPackageButton: UIButton = {
    let button = UIButton()
    button.setTitle("10", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .systemRed.withAlphaComponent(0.2)
    button.layer.cornerRadius = 15
    return button
  }()
  
  private let largePackageButton: UIButton = {
    let button = UIButton()
    button.setTitle("15", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .systemRed.withAlphaComponent(0.2)
    button.layer.cornerRadius = 15
    return button
  }()
  
  private let packageDescriptionTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 15
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.backgroundColor = Theme.Views.GameCurrency.textViewBackground
    textView.textAlignment = .center
    textView.text = "Такого количества бриллиантов хватит что бы купить всех редких птиц! Этономия 50%"
    return textView
  }()
  
  private let buyButton: UIButton = {
    let button = UIButton()
    button.cornerRadius = 15
    button.setTitle("Купить!", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.Cerise
    return button
  }()
  
  // MARK: - MVVM
  public var viewModel: ScoreViewModel!
  
  // MARK: - RX Elements
  private let disposeBag = DisposeBag()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    configureHeader()
    configureBody()
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
    titleLabel.text = "Валюта"
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
    
    // adding
    view.addSubview(featherImageView)
    view.addSubview(diamondImageView)
    view.addSubview(featherDescriptionTextView)
    view.addSubview(diamondDescriptionTextView)
    view.addSubview(smallPackageButton)
    view.addSubview(mediumPackageButton)
    view.addSubview(largePackageButton)
    view.addSubview(packageDescriptionTextView)
    view.addSubview(buyButton)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // featherImageView
    featherImageView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16, widthConstant: 75, heightConstant: 100)
    
    // featherDescriptionTextView
    featherDescriptionTextView.anchor(top: featherImageView.topAnchor, left: featherImageView.rightAnchor, bottom: featherImageView.bottomAnchor, right: view.rightAnchor, leftConstant: 16, rightConstant: 16)
    
    // diamondImageView
    diamondImageView.anchor(top: featherImageView.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16, widthConstant: 75, heightConstant: 100)
    
    // diamondDescriptionTextView
    diamondDescriptionTextView.anchor(top: diamondImageView.topAnchor, left: diamondImageView.rightAnchor, bottom: diamondImageView.bottomAnchor, right: view.rightAnchor, leftConstant: 16, rightConstant: 16)
    
    // buy buttons
    let widthConstant = (UIScreen.main.bounds.width - 16 * 4)/3
    
    // smallPackageButton
    smallPackageButton.anchor(top: diamondImageView.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16, widthConstant: widthConstant, heightConstant: widthConstant * 1.5 )
    
    // mediumPackageButton
    mediumPackageButton.anchor(top: diamondImageView.bottomAnchor, left: smallPackageButton.rightAnchor, topConstant: 16, leftConstant: 16, widthConstant: widthConstant, heightConstant: widthConstant * 1.5 )
    
    // largePackageButton
    largePackageButton.anchor(top: diamondImageView.bottomAnchor, left: mediumPackageButton.rightAnchor, topConstant: 16, leftConstant: 16, widthConstant: widthConstant, heightConstant: widthConstant * 1.5 )
    
    // packageDescriptionTextView
    packageDescriptionTextView.anchor(top: smallPackageButton.bottomAnchor, left: view.leftAnchor,  right: view.rightAnchor, topConstant: 16, leftConstant: 16,  rightConstant: 16,  heightConstant: 50)
    
    // buyButton
    buyButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, leftConstant: 16, bottomConstant: 32, rightConstant: 16, heightConstant: 50)
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
    
    let input = ScoreViewModel.Input(
      backButtonClickHandler: backButton.rx.tap.asDriver(),
      buyButtonClickTrigger: buyButton.rx.tap.asDriver()
    )
    
    let output = viewModel.transform(input: input)
    
    [
      output.buyButtonClickHandler.drive(),
      output.backButtonClickHandler.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  
  
}

