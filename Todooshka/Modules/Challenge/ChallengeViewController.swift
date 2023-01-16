//
//  ChallengeViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.
//

import RxCocoa
import RxSwift

class ChallengeViewController: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: ChallengeViewModel!
  
  // MARK: - UI Elements
  private let addImageButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.plus.image.template, for: .normal)
    button.tintColor = .black
    button.cornerRadius = 75.0 / 2
    button.borderWidth = 1.0
    button.borderColor = .black
    return button
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .systemRed.withAlphaComponent(0.2)
    imageView.isHidden = true
    return imageView
  }()
  
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "Название:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let nameTextField: UITextField = {
    let textField = UITextField()
    textField.cornerRadius = 5
    textField.borderWidth = 1.0
    textField.borderColor = .black
    return textField
  }()
  
  private let rankLabel: UILabel = {
    let label = UILabel()
    label.text = "Звание за завершение:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let rankTextField: UITextField = {
    let textField = UITextField()
    textField.cornerRadius = 5
    textField.borderWidth = 1.0
    textField.borderColor = .black
    return textField
  }()
  
  private let challengeLabel: UILabel = {
    let label = UILabel()
    label.text = "Что надо сделать:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let challengeTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 5.0
    textView.borderWidth = 1.0
    textView.borderColor = .black
    textView.backgroundColor = .clear
    return textView
  }()
  
  private let challengeImageLabel: UILabel = {
    let label = UILabel()
    label.text = "Фотоподсказки (необязательно):"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let checkLabel: UILabel = {
    let label = UILabel()
    label.text = "Как проверим:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let checkTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 5.0
    textView.borderWidth = 1.0
    textView.borderColor = .black
    textView.backgroundColor = .clear
    return textView
  }()
  
  private let exampleLabel: UILabel = {
    let label = UILabel()
    label.text = "Пример выполнения (необязательно):"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  func configureUI() {
    backButton.isHidden = false
    hideKeyboardWhenTappedAround()
    
    view.addSubviews([
      addImageButton,
      imageView,
      nameLabel,
      nameTextField,
      rankLabel,
      rankTextField,
      challengeLabel,
      challengeTextView,
      checkLabel,
      checkTextView,
      exampleLabel
    ])
    
    // addImageButton
    addImageButton.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 75,
      heightConstant: 75
    )
    
    // imageView
    imageView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 75,
      heightConstant: 75
    )
    
    // nameLabel
    nameLabel.anchor(
      top: headerView.bottomAnchor,
      left: addImageButton.rightAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    // nameTextField
    nameTextField.anchor(
      top: nameLabel.bottomAnchor,
      left: addImageButton.rightAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 40
    )
    
    // rankLabel
    rankLabel.anchor(
      top: nameTextField.bottomAnchor,
      left: addImageButton.rightAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    // rankTextField
    rankTextField.anchor(
      top: rankLabel.bottomAnchor,
      left: addImageButton.rightAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 40
    )
    
    // challengeLabel
    challengeLabel.anchor(
      top: rankTextField.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    // challengeTextView
    challengeTextView.anchor(
      top: challengeLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 75
    )
    
    // checkLabel
    checkLabel.anchor(
      top: challengeTextView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
    
    // checkTextView
    checkTextView.anchor(
      top: checkLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 75
    )
    
    // exampleLabel
    exampleLabel.anchor(
      top: checkTextView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
  }
  
  func bindViewModel() {
    let input = ChallengeViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.navigateBack.drive(),
      outputs.openViewControllerMode.drive(openViewControllerModeBinder)
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  var openViewControllerModeBinder: Binder<OpenViewControllerMode> {
    return Binder(self, binding: { vc, mode in
      switch mode {
      case .edit:
        vc.addImageButton.isHidden = false
        vc.imageView.isHidden = true
      case .view:
        vc.addImageButton.isHidden = true
        vc.imageView.isHidden = false
      }
    })
  }
}
