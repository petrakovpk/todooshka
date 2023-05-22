//
//  LoginViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa
import RxDataSources

class LoginViewController: UIViewController {
  public var viewModel: LoginViewModel!
  
  private let disposeBag = DisposeBag()

  // MARK: - UI Elements
  private let headerView = UIView()

  private let headerLabel: UILabel = {
    let label = UILabel()
    label.text = "DragoDo"
    label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    label.textColor = Style.App.text
    return label
  }()

  private let secondHeaderLabel: UILabel = {
    let label = UILabel()
    label.text = "Создаем аккаунт"
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    label.textColor = Style.App.text
    return label
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

  private let headerDescriptionTextView: UITextView = {
    let textView = UITextView()
    textView.text = "Спасибо, что решили зарегестрировать в приложении! Это поможет вам сохранять онлайн задачи и загружать их на других устройствах!"
    textView.isScrollEnabled = false
    textView.isSelectable = false
    textView.isEditable = false
    textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    textView.textAlignment = .center
    textView.backgroundColor = .clear
    textView.textColor = Palette.SingleColors.SantasGray
    return textView
  }()

  private let emailButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium) ])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()

  private let phoneButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Телефон", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()

  private let emailTextField = TDAuthTextField(type: .email)
  private let passwordTextField = TDAuthTextField(type: .password)
  private let repeatPasswordTextField = TDAuthTextField(type: .repeatPassword)
  private let phoneTextField = TDAuthTextField(type: .phone)
  private let OTPCodeTextField = TDAuthTextField(type: .otp)

  private let resetPasswordButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Забыли пароль?\nОтправить письмо для восстановления пароля", for: .normal)
    button.setTitleColor(Palette.SingleColors.SantasGray, for: .normal)
    button.titleLabel?.lineBreakMode = .byWordWrapping
    button.titleLabel?.textAlignment = .center
    return button
  }()

  private let sendOTPCodeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Отправить код повторно", for: .normal)
    button.setTitleColor(Palette.SingleColors.SantasGray, for: .normal)
    button.titleLabel?.lineBreakMode = .byWordWrapping
    button.titleLabel?.textAlignment = .center
    return button
  }()

  private let nextButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 48 / 2
    button.setTitle("Далее", for: .normal)
    return button
  }()

  private let backButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(Icon.arrowLeft.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()

  private let leftDividerView: UIView = {
    let view = UIView()
    return view
  }()

  private let rightDividerView: UIView = {
    let view = UIView()
    return view
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    // adding
    view.addSubview(headerView)
    view.addSubview(headerLabel)
    view.addSubview(secondHeaderLabel)
    view.addSubview(headerDescriptionTextView)
    view.addSubview(emailButton)
    view.addSubview(phoneButton)
    view.addSubview(leftDividerView)
    view.addSubview(rightDividerView)
    view.addSubview(emailTextField)
    view.addSubview(passwordTextField)
    view.addSubview(phoneTextField)
    view.addSubview(OTPCodeTextField)
    view.addSubview(nextButton)
    view.addSubview(repeatPasswordTextField)
    view.addSubview(errorTextView)
    view.addSubview(resetPasswordButton)
    view.addSubview(sendOTPCodeButton)
    headerView.addSubview(backButton)

    // view
    view.backgroundColor = Style.Auth.Background

    // headerView
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: 96)

    // backButton
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)

    // headerLabel
    headerLabel.anchor(top: view.topAnchor, topConstant: 84)
    headerLabel.anchorCenterXToSuperview()

    // secondHeaderLabel
    secondHeaderLabel.anchor(top: headerLabel.bottomAnchor, topConstant: 31)
    secondHeaderLabel.anchorCenterXToSuperview()

    // headerDescriptionTextView
    headerDescriptionTextView.anchor(top: secondHeaderLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 15, leftConstant: 29, rightConstant: 29)
    headerDescriptionTextView.anchorCenterXToSuperview()

    // emailButton
    emailButton.anchor(top: headerDescriptionTextView.bottomAnchor, left: view.leftAnchor,              topConstant: 20, widthConstant: UIScreen.main.bounds.width / 2, heightConstant: 50)

    // phoneButton
    phoneButton.anchor(top: headerDescriptionTextView.bottomAnchor, right: view.rightAnchor, topConstant: 20, widthConstant: UIScreen.main.bounds.width / 2, heightConstant: 50)

    // leftDividerView
    leftDividerView.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: emailButton.rightAnchor, heightConstant: 1)

    // rightDividerView
    rightDividerView.anchor(top: phoneButton.bottomAnchor, left: phoneButton.leftAnchor, right: view.rightAnchor, heightConstant: 1)

    // emailTextField

    emailTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 54)

    // passwordTextField

    passwordTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 54)

    // resetPasswordButton
    resetPasswordButton.anchor(top: passwordTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 54)

    // sendOTPCodeButton
    sendOTPCodeButton.anchor(top: passwordTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 54)

    // phoneTextField

    phoneTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 54)

    // codeTextField

    OTPCodeTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 54)

    // repeatPasswordTextField

    repeatPasswordTextField.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 54)

    // nextButton
    nextButton.anchor(top: repeatPasswordTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 48)

    // errorTextView
    errorTextView.anchor(top: nextButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16,              heightConstant: 50)
  }

  // MARK: - Bind
  func bindViewModel() {
    let input = LoginViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      // buttons
      emailButtonClickTrigger: emailButton.rx.tap.asDriver(),
      phoneButtonClickTrigger: phoneButton.rx.tap.asDriver(),
      // text fields - 1st screen
      emailTextFieldText: emailTextField.rx.text.orEmpty.asDriver(),
      phoneTextFieldText: phoneTextField.rx.text.orEmpty.asDriver(),
      // text fields - 1st screen events
      emailTextFieldDidEndEditing: emailTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      phoneTextFieldDidEndEditing: phoneTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      // text fields - 2nd screen
      passwordTextFieldText: passwordTextField.rx.text.orEmpty.asDriver(),
      repeatPasswordTextFieldText: repeatPasswordTextField.rx.text.orEmpty.asDriver(),
      OTPCodeTextFieldText: OTPCodeTextField.rx.text.orEmpty.asDriver(),
      // text fields - 2nd screen - events
      passwordTextFieldDidEndEditing: passwordTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      repeatPasswordTextFieldDidEndEditing: repeatPasswordTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      OTPCodeTextFieldDidEndEditing: OTPCodeTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      // next button
      nextButtonClickTrigger: nextButton.rx.tap.asDriver(),
      // bottom buttons
      resetPasswordButtonClickTrigger: resetPasswordButton.rx.tap.asDriver(),
      sendOTPCodeButtonClickTriger: sendOTPCodeButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      // header
      outputs.navigateBack.drive(),
      // style
      outputs.loginViewControllerStyle.drive(loginViewControllerStyleBinder),
      outputs.loginViewControllerStyleHandler.drive(),
      // email
      outputs.sendEmailVerification.drive(),
      // phone
      outputs.phoneNumberTextField.drive(phoneTextField.rx.text),
      // repeat password
      outputs.setFocusOnRepeatPasswordTextField.drive(setFocusOnRepeatPasswordTextFieldBinder),
      // next button
      outputs.nextButtonIsEnabled.drive(setNextButtonIsEnabledBinder),
      // auth
      outputs.auth.drive(),
      // error
      outputs.errorText.drive(errorTextView.rx.text)
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }

  var setNextButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in
      if isEnabled {
        vc.nextButton.backgroundColor = Style.Buttons.NextButton.EnabledBackground
        vc.nextButton.setTitleColor(.white, for: .normal)
        vc.nextButton.isEnabled = true
      } else {
        vc.nextButton.backgroundColor = Style.Buttons.NextButton.DisabledBackground
        vc.nextButton.setTitleColor(Style.App.text?.withAlphaComponent(0.12), for: .normal)
        vc.nextButton.isEnabled = false
      }
      
    })
  }

  var setSendOTPCodeButtonClickSuccessBinder: Binder<String> {
    return Binder(self, binding: { vc, text in
      vc.sendOTPCodeButton.setTitle(text, for: .normal)
    })
  }

  var setResetPasswordButtonClickSuccessBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.resetPasswordButton.setTitle("text", for: .normal)
    })
  }

  var setFocusOnRepeatPasswordTextFieldBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.repeatPasswordTextField.becomeFirstResponder()
    })
  }

  var loginViewControllerStyleBinder: Binder<LoginViewControllerStyle> {
    return Binder(self, binding: { vc, loginViewControllerStyle in
      switch loginViewControllerStyle {
      case .email:
        vc.leftDividerView.backgroundColor = Style.Views.AuthDivider.selected
        vc.rightDividerView.backgroundColor = Style.Views.AuthDivider.unselected
        vc.emailButton.setTitleColor(Style.Views.AuthDivider.selectedText, for: .normal)
        vc.phoneButton.setTitleColor(Style.Views.AuthDivider.unselectedText, for: .normal)
        vc.emailTextField.isHidden = false
        vc.phoneTextField.isHidden = true
        vc.passwordTextField.isHidden = true
        vc.repeatPasswordTextField.isHidden = true
        vc.OTPCodeTextField.isHidden = true
        vc.resetPasswordButton.isHidden = true
        vc.sendOTPCodeButton.isHidden = true
        vc.emailTextField.becomeFirstResponder()
      case .password:
        vc.leftDividerView.backgroundColor = Style.Views.AuthDivider.selected
        vc.rightDividerView.backgroundColor = Style.Views.AuthDivider.unselected
        vc.emailButton.setTitleColor(Style.Views.AuthDivider.selectedText, for: .normal)
        vc.phoneButton.setTitleColor(Style.Views.AuthDivider.unselectedText, for: .normal)
        vc.emailTextField.isHidden = true
        vc.phoneTextField.isHidden = true
        vc.passwordTextField.isHidden = false
        vc.repeatPasswordTextField.isHidden = true
        vc.OTPCodeTextField.isHidden = true
        vc.resetPasswordButton.isHidden = false
        vc.sendOTPCodeButton.isHidden = true
        vc.passwordTextField.clear()
        vc.repeatPasswordTextField.clear()
        vc.passwordTextField.becomeFirstResponder()
        vc.resetPasswordButton.setTitle("Забыли пароль?\nОтправить письмо для восстановления пароля", for: .normal)
      case .repeatPassword:
        vc.leftDividerView.backgroundColor = Style.Views.AuthDivider.selected
        vc.rightDividerView.backgroundColor = Style.Views.AuthDivider.unselected
        vc.emailButton.setTitleColor(Style.Views.AuthDivider.selectedText, for: .normal)
        vc.phoneButton.setTitleColor(Style.Views.AuthDivider.unselectedText, for: .normal)
        vc.emailTextField.isHidden = true
        vc.phoneTextField.isHidden = true
        vc.passwordTextField.isHidden = false
        vc.repeatPasswordTextField.isHidden = false
        vc.OTPCodeTextField.isHidden = true
        vc.resetPasswordButton.isHidden = true
        vc.sendOTPCodeButton.isHidden = true
        vc.passwordTextField.clear()
        vc.repeatPasswordTextField.clear()
        vc.passwordTextField.becomeFirstResponder()
      case .phone:
        vc.leftDividerView.backgroundColor = Style.Views.AuthDivider.unselected
        vc.rightDividerView.backgroundColor = Style.Views.AuthDivider.selected
        vc.emailButton.setTitleColor(Style.Views.AuthDivider.unselectedText, for: .normal)
        vc.phoneButton.setTitleColor(Style.Views.AuthDivider.selectedText, for: .normal)
        vc.emailTextField.isHidden = true
        vc.phoneTextField.isHidden = false
        vc.passwordTextField.isHidden = true
        vc.repeatPasswordTextField.isHidden = true
        vc.OTPCodeTextField.isHidden = true
        vc.resetPasswordButton.isHidden = true
        vc.sendOTPCodeButton.isHidden = true
        vc.phoneTextField.becomeFirstResponder()
      case .otp:
        vc.leftDividerView.backgroundColor = Style.Views.AuthDivider.unselected
        vc.rightDividerView.backgroundColor = Style.Views.AuthDivider.selected
        vc.emailButton.setTitleColor(Style.Views.AuthDivider.unselectedText, for: .normal)
        vc.phoneButton.setTitleColor(Style.Views.AuthDivider.selectedText, for: .normal)
        vc.emailTextField.isHidden = true
        vc.phoneTextField.isHidden = true
        vc.passwordTextField.isHidden = true
        vc.repeatPasswordTextField.isHidden = true
        vc.OTPCodeTextField.isHidden = false
        vc.resetPasswordButton.isHidden = true
        vc.sendOTPCodeButton.isHidden = false
        vc.OTPCodeTextField.becomeFirstResponder()
        vc.OTPCodeTextField.clear()
        vc.sendOTPCodeButton.setTitle("Отправить код повторно", for: .normal)
      }
    })
  }
}
