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
  private let textField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Название задачи"
    textField.borderColor = .black
    textField.borderWidth = 1.0
    textField.cornerRadius = 5
    return textField
  }()
  
  private let manualLabel: UILabel = {
    let label = UILabel()
    label.text = "Инструкция"
    return label
  }()
  
  private let manualTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 3.0
    textView.backgroundColor = .clear
    textView.borderWidth = 1.0
    textView.borderColor = .black
    return textView
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
      textField,
      manualLabel,
      manualTextView
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
    
    // manualLabel
    manualLabel.anchor(
      top: textField.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    // manualTextView
    manualTextView.anchor(
      top: manualLabel.bottomAnchor,
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
      outputs.navigateBack.drive()
      
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
}

