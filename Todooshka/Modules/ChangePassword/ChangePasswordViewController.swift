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
    textView.text = "Введите новый пароль (не менее 8 символов)"
    textView.backgroundColor = .clear
    return textView
  }()

  private let newPasswordTextField: TDAuthTextField = {
    let textField = TDAuthTextField(type: .password)
    textField.borderColor = Style.TextFields.SettingsTextField.Border
    textField.backgroundColor = Style.TextFields.SettingsTextField.Background
    textField.imageView.tintColor = Style.TextFields.SettingsTextField.Tint
    return textField
  }()

  private let repeatNewPasswordTextField: TDAuthTextField = {
    let textField = TDAuthTextField(type: .repeatPassword)
    textField.borderColor = Style.TextFields.SettingsTextField.Border
    textField.backgroundColor = Style.TextFields.SettingsTextField.Background
    textField.imageView.tintColor = Style.TextFields.SettingsTextField.Tint
    return textField
  }()

  private let setPasswordButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 13
    button.setTitle("Установить пароль", for: .normal)
    return button
  }()

  private let errorTextView: UITextView = {
    let textView = UITextView()
    textView.textAlignment = .center
    textView.isEditable = false
    textView.isSelectable = false
    textView.font = UIFont.systemFont(ofSize: 12, weight: .light)
    textView.textColor = UIColor(red: 0.937, green: 0.408, blue: 0.322, alpha: 1)
    textView.backgroundColor = .clear
    return textView
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
    backButton.isHidden = false
    saveButton.isHidden = false

    // adding
    view.addSubviews([
      textView,
      newPasswordTextField,
      repeatNewPasswordTextField,
      setPasswordButton,
      errorTextView
    ])

    //  header
    titleLabel.text = "Сменить пароль"

    // textView
    textView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 30
    )

    // passwordTextField
    newPasswordTextField.becomeFirstResponder()
    newPasswordTextField.anchor(
      top: textView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )

    // repeatPasswordTextField
    repeatNewPasswordTextField.anchor(
      top: newPasswordTextField.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )

    // setPasswordButton
    setPasswordButton.anchor(
      top: repeatNewPasswordTextField.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )

    // errorTextView
    errorTextView.anchor(
      top: setPasswordButton.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = ChangePasswordViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      passwordTextFieldText: newPasswordTextField.rx.text.orEmpty.asDriver(),
      repeatPasswordTextFieldText: repeatNewPasswordTextField.rx.text.orEmpty.asDriver(),
      setPasswordButtonClickTrigger: setPasswordButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.errorText.drive(errorTextView.rx.text),
      outputs.navigateBack.drive(),
      outputs.setPasswordButtonIsEnabled.drive(setPasswordButtonIsEnabledBinder),
      outputs.setPassword.drive(setPasswordBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }

  var setPasswordButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in
      vc.setPasswordButton.backgroundColor = isEnabled ? Style.Buttons.NextButton.EnabledBackground : Style.Buttons.NextButton.DisabledBackground
      vc.setPasswordButton.setTitleColor(isEnabled ? .white : Style.App.text?.withAlphaComponent(0.12), for: .normal)
      vc.setPasswordButton.isEnabled = isEnabled
    })
  }

  var setPasswordBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.newPasswordTextField.clear()
      vc.repeatNewPasswordTextField.clear()
      vc.newPasswordTextField.insertText("")
      vc.repeatNewPasswordTextField.insertText("")
    })
  }
}
