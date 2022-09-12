//
//  ChangePasswordViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ChangePasswordViewController: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - MVVM
  public var viewModel: ChangePasswordViewModel!
  
  // MARK: - UI Elemenets
  private let textView: UITextView = {
    let textView = UITextView()
    textView.isEditable = false
    textView.isSelectable = false
    textView.text = "Пароль должен содержать не менее 8 символов"
    textView.backgroundColor = .clear
    return textView
  }()
  
  private let passwordTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Новый пароль"
    textField.isSecureTextEntry = true
    textField.cornerRadius = 5
    textField.borderWidth = 1
    textField.borderColor = Theme.App.text
    textField.backgroundColor = Theme.App.background
    return textField
  }()
  
  private let repeatPasswordTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Повторите новый пароль"
    textField.isSecureTextEntry = true
    textField.cornerRadius = 5
    textField.borderWidth = 1
    textField.borderColor = Theme.App.text
    return textField
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  // MARK: - Configure UI
  func configureUI() {
    // settings
    saveButton.isHidden = false
    
    // adding
    view.addSubview(textView)
    view.addSubview(passwordTextField)
    view.addSubview(repeatPasswordTextField)
    
    //  header
    titleLabel.text = "Сменить пароль"
    
    // textView
    textView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 30)
    
    // passwordTextField
    passwordTextField.becomeFirstResponder()
    passwordTextField.anchor(top: textView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 40)
    
    // repeatPasswordTextField
    repeatPasswordTextField.anchor(top: passwordTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16, heightConstant: 40)
  }
  
  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    
    let input = ChangePasswordViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.navigateBack.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
}
