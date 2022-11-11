//
//  ThemeViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.11.2022.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class ThemeViewController: TDViewController {

  // MARK: - MVVM
  public var viewModel: ThemeViewModel!

  // MARK: - RX Elements
  private let disposeBag = DisposeBag()

  // MARK: - UI Elements
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .systemRed.withAlphaComponent(0.2)
    return imageView
  }()

  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 15
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.font = UIFont.systemFont(ofSize: 12, weight: .thin)
    textView.text = "bla bla bla"
    textView.textAlignment = .center
    return textView
  }()

  private let startButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 15
    button.setTitle("Начать курс", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.borderWidth = 1.0
    button.borderColor = .systemGray.withAlphaComponent(0.3)
    return button
  }()

  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<ThemeSection>!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    descriptionTextView.centerVerticalText()
  }

  func configureUI() {
    // header
    backButton.isHidden = false
    hideKeyboardWhenTappedAround()
    
    // adding
    view.addSubviews([
      imageView,
      descriptionTextView,
      startButton
    ])
    
    // imageView
    imageView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 150,
      heightConstant: 150)
    
    // descriptionTextView
    descriptionTextView.anchor(
      top: headerView.bottomAnchor,
      left: imageView.rightAnchor,
      bottom: imageView.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16)
    
    // startButton
    startButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: 50)
  }

  // MARK: - Bind View Model
  func bindViewModel() {
    let input = ThemeViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )

    let output = viewModel.transform(input: input)

    [
      output.name.drive(titleLabel.rx.text),
      output.navigateBack.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
}
