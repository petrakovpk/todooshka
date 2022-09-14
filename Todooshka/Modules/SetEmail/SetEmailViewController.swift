//
//  ChangeEmailViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SetEmailViewController: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - MVVM
  public var viewModel: SetEmailViewModel!
  
  // MARK: - UI Elemenets
  private let currentEmailLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  private let sendVerificationEmailButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 13
    button.setTitle("Отправить письмо с подтверждением", for: .normal)
    return button
  }()
  
  private let newEmailLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.text = "Введите новый основной email:"
    return label
  }()
  
  private let changeEmailButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 13
    button.setTitle("Установить новый email", for: .normal)
    return button
  }()
  
  
  private let currentEmailTextField = TDAuthTextField(type: .Email)
  private let newEmailTextField = TDAuthTextField(type: .Email)
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  // MARK: - Configure UI
  func configureUI() {
    // adding
    view.addSubviews([
      currentEmailLabel,
      currentEmailTextField,
      sendVerificationEmailButton,
      newEmailLabel,
      newEmailTextField,
      changeEmailButton
    ])
    
    //  header
    titleLabel.text = "Email"
    
    // emailLabel
    currentEmailLabel.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16)
    
    // emailTextField
    currentEmailTextField.isEnabled = false
    currentEmailTextField.anchor(top: currentEmailLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 50)
    
    // nextButton
    sendVerificationEmailButton.anchor(top: currentEmailTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 50)
    
    // newEmailLabel
    newEmailLabel.anchor(top: sendVerificationEmailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16)
  
    // newEmailTextField
    newEmailTextField.anchor(top: newEmailLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 50)

    // changeEmailButton
    changeEmailButton.anchor(top: newEmailTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16,  heightConstant: 50)
  }
  
  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    
    let input = SetEmailViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      emailTextFieldText: currentEmailTextField.rx.text.orEmpty.asDriver(),
      sendVerificationEmailButtonClick: sendVerificationEmailButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.emailLabelText.drive(currentEmailLabel.rx.text),
      outputs.emailTextFieldText.drive(currentEmailTextField.rx.text),
      outputs.navigateBack.drive(),
      outputs.sendEmailVerification.drive(),
      outputs.sendVerificationEmailButtonIsEnabled.drive(sendVerificationEmailButtonIsEnabledBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  var sendVerificationEmailButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { (vc, isEnabled) in
      vc.sendVerificationEmailButton.backgroundColor = isEnabled ? Palette.SingleColors.BlueRibbon : Palette.DualColors.Mischka_205_205_223_
      vc.sendVerificationEmailButton.setTitleColor(isEnabled ? .white : Theme.App.text?.withAlphaComponent(0.12) , for: .normal)
      vc.sendVerificationEmailButton.isEnabled = isEnabled
    })
  }
}

