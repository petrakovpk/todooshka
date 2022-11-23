//
//  ThemeTaskViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.
//

import RxCocoa
import RxSwift

class ThemeTaskViewController: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - MVVM
  public var viewModel: ThemeTaskViewModel!
  
  // MARK: - UI Elements
  private let addImageButton: UIButton = {
    let button = UIButton(type: .system)
    button.borderColor = .black
    button.borderWidth = 1.0
    button.cornerRadius = 15
    button.setImage(Icon.plus.image.template, for: .normal)
    button.tintColor = .black
    return button
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "Инструкция"
    return label
  }()
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 3.0
    textView.backgroundColor = .clear
    textView.borderWidth = 1.0
    textView.borderColor = .black
    return textView
  }()
  
  private let textField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Название задачи"
    textField.borderColor = .black
    textField.borderWidth = 1.0
    textField.cornerRadius = 5
    return textField
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
      descriptionLabel,
      descriptionTextView,
      textField
    ])
    
    // textField
    textField.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 30
    )
    
    // descriptionLabel
    descriptionLabel.anchor(
      top: textField.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    // addImageButton
    addImageButton.anchor(
      top: descriptionLabel.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 75.0,
      heightConstant: 75.0
    )
    
    // descriptionTextView
    descriptionTextView.anchor(
      top: addImageButton.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 100
    )
  }
  
  func bindViewModel() {
    let input = ThemeTaskViewModel.Input(
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
        vc.descriptionTextView.isEditable = true
        vc.saveButton.isHidden = false
        vc.textField.isEnabled = true
      case .view:
        vc.textField.isEnabled = false
        vc.saveButton.isHidden = true
        vc.descriptionTextView.isEditable = false
      }
    })
  }
}

