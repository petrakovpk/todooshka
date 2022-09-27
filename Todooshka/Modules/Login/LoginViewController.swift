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
  
  //MARK: - Properties
  var viewModel: LoginViewModel!
  private let disposeBag = DisposeBag()
  
  //MARK: - UI Elements
  fileprivate let headerView = UIView()
  
  fileprivate let headerLabel: UILabel = {
    let label = UILabel()
    label.text = "TODOOSHKA"
    label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    label.textColor = Theme.App.text
    return label
  }()
  
  fileprivate let secondHeaderLabel: UILabel = {
    let label = UILabel()
    label.text = "Создаем аккаунт"
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    label.textColor = Theme.App.text
    return label
  }()
  
  fileprivate let errorTextView: UITextView = {
    let textView = UITextView()
    textView.textAlignment = .center
    textView.isEditable = false
    textView.isSelectable = false
    textView.font = UIFont.systemFont(ofSize: 12, weight: .light)
    textView.textColor = UIColor(red: 0.937, green: 0.408, blue: 0.322, alpha: 1)
    textView.backgroundColor = .clear
    return textView
  }()
  
  fileprivate let headerDescriptionTextView: UITextView = {
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
  
  fileprivate let emailButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium) ])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  fileprivate let phoneButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Телефон", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  fileprivate let emailTextField = TDAuthTextField(type: .Email)
  fileprivate let passwordTextField = TDAuthTextField(type: .Password)
  fileprivate let repeatPasswordTextField = TDAuthTextField(type: .RepeatPassword)
  fileprivate let phoneTextField = TDAuthTextField(type: .Phone)
  fileprivate let OTPCodeTextField = TDAuthTextField(type: .OTPCode)
  
  fileprivate let resetPasswordButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Забыли пароль?\nОтправить письмо для восстановления пароля", for: .normal)
    button.setTitleColor(Palette.SingleColors.SantasGray, for: .normal)
    button.titleLabel?.lineBreakMode = .byWordWrapping
    button.titleLabel?.textAlignment = .center
    return button
  }()
  
  fileprivate let sendOTPCodeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Отправить код повторно", for: .normal)
    button.setTitleColor(Palette.SingleColors.SantasGray, for: .normal)
    button.titleLabel?.lineBreakMode = .byWordWrapping
    button.titleLabel?.textAlignment = .center
    return button
  }()
  
  fileprivate let nextButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 48 / 2
    button.setTitle("Далее", for: .normal)
    return button
  }()
  
  fileprivate let backButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    button.tintColor = Theme.App.text
    return button
  }()
  
  fileprivate let leftDividerView: UIView = {
    let view = UIView()
    return view
  }()
  
  fileprivate let rightDividerView: UIView = {
    let view = UIView()
    return view
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  //MARK: - Configure UI
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
    view.backgroundColor = Theme.Auth.Background
    
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
    emailButton.anchor(top: headerDescriptionTextView.bottomAnchor, left: view.leftAnchor,  topConstant: 20, widthConstant: UIScreen.main.bounds.width / 2, heightConstant: 50)
    
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
    errorTextView.anchor(top: nextButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16,  heightConstant: 50)
  }
  
  //MARK: - Bind
  func bindViewModel() {
    
    let input = LoginViewModel.Input(
      emailTextFieldText: emailTextField.rx.text.orEmpty.asDriver(),
      OTPCodeTextFieldText: OTPCodeTextField.rx.text.orEmpty.asDriver(),
      passwordTextFieldText: passwordTextField.rx.text.orEmpty.asDriver(),
      phoneTextFieldText: phoneTextField.rx.text.orEmpty.asDriver(),
      repeatPasswordTextFieldText: repeatPasswordTextField.rx.text.orEmpty.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      emailButtonClickTrigger: emailButton.rx.tap.asDriver(),
      nextButtonClickTrigger: nextButton.rx.tap.asDriver(),
      phoneButtonClickTrigger: phoneButton.rx.tap.asDriver(),
      emailTextFieldDidEndEditing: emailTextField.rx.controlEvent(.editingDidEndOnExit).asDriver() ,
      passwordTextFieldDidEndEditing: passwordTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      repeatPasswordTextFieldDidEndEditing: repeatPasswordTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      phoneTextFieldDidEndEditing: phoneTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      OTPCodeTextFieldDidEndEditing: OTPCodeTextField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      resetPasswordButtonClickTrigger: resetPasswordButton.rx.tap.asDriver(),
      sendOTPCodeButtonClickTriger: sendOTPCodeButton.rx.tap.asDriver()
    )
    
    let output = viewModel.transform(input: input)
    
    [
      output.auth.drive(),
      output.correctNumber.drive(phoneTextField.rx.text),
      output.errorText.drive(errorTextView.rx.text),
      output.navigateBack.drive(),
      output.nextButtonIsEnabled.drive(setNextButtonIsEnabledBinder),
      output.sendEmailVerification.drive(),
      output.setLoginViewControllerStyle.drive(loginViewControllerStyleBinder),
      output.setFocusOnRepeatPasswordTextField.drive(setFocusOnRepeatPasswordTextFieldBinder),
      output.updateUserData.drive(),
      output.setResetPasswordButtonClickSuccess.drive(setResetPasswordButtonClickSuccessBinder),
      output.setSendOTPCodeButtonClickSuccess.drive(setSendOTPCodeButtonClickSuccessBinder)
    ]
      .forEach{ $0.disposed(by: disposeBag) }
  }
  
  var setNextButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { (vc, isEnabled) in
      vc.nextButton.backgroundColor = isEnabled ? Theme.Buttons.NextButton.EnabledBackground : Theme.Buttons.NextButton.DisabledBackground
      vc.nextButton.setTitleColor(isEnabled ? .white : Theme.App.text?.withAlphaComponent(0.12) , for: .normal)
      vc.nextButton.isEnabled = isEnabled
    })
  }
  
  var setSendOTPCodeButtonClickSuccessBinder: Binder<String> {
    return Binder(self, binding: { (vc, text) in
      vc.sendOTPCodeButton.setTitle(text, for: .normal)
    })
  }
  
  var setResetPasswordButtonClickSuccessBinder: Binder<String> {
    return Binder(self, binding: { (vc, text) in
      vc.resetPasswordButton.setTitle(text, for: .normal)
    })
  }
  
  var setFocusOnRepeatPasswordTextFieldBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.repeatPasswordTextField.becomeFirstResponder()
    })
  }
  
  
  var loginViewControllerStyleBinder: Binder<LoginViewControllerStyle> {
    return Binder(self, binding: { (vc, loginViewControllerStyle) in
      switch loginViewControllerStyle {
      case .Email:
        vc.leftDividerView.backgroundColor = Theme.Divider.selected
        vc.rightDividerView.backgroundColor = Theme.Divider.unselected
        vc.emailButton.setTitleColor(Theme.Divider.selectedText , for: .normal)
        vc.phoneButton.setTitleColor(Theme.Divider.unselectedText, for: .normal)
        vc.emailTextField.isHidden = false
        vc.phoneTextField.isHidden = true
        vc.passwordTextField.isHidden = true
        vc.repeatPasswordTextField.isHidden = true
        vc.OTPCodeTextField.isHidden = true
        vc.resetPasswordButton.isHidden = true
        vc.sendOTPCodeButton.isHidden = true
        vc.emailTextField.becomeFirstResponder()
      case .Password:
        vc.leftDividerView.backgroundColor = Theme.Divider.selected
        vc.rightDividerView.backgroundColor = Theme.Divider.unselected
        vc.emailButton.setTitleColor(Theme.Divider.selectedText, for: .normal)
        vc.phoneButton.setTitleColor(Theme.Divider.unselectedText, for: .normal)
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
      case .RepeatPassword:
        vc.leftDividerView.backgroundColor = Theme.Divider.selected
        vc.rightDividerView.backgroundColor = Theme.Divider.unselected
        vc.emailButton.setTitleColor(Theme.Divider.selectedText, for: .normal)
        vc.phoneButton.setTitleColor(Theme.Divider.unselectedText, for: .normal)
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
      case .Phone:
        vc.leftDividerView.backgroundColor = Theme.Divider.unselected
        vc.rightDividerView.backgroundColor = Theme.Divider.selected
        vc.emailButton.setTitleColor(Theme.Divider.unselectedText, for: .normal)
        vc.phoneButton.setTitleColor(Theme.Divider.selectedText, for: .normal)
        vc.emailTextField.isHidden = true
        vc.phoneTextField.isHidden = false
        vc.passwordTextField.isHidden = true
        vc.repeatPasswordTextField.isHidden = true
        vc.OTPCodeTextField.isHidden = true
        vc.resetPasswordButton.isHidden = true
        vc.sendOTPCodeButton.isHidden = true
        vc.phoneTextField.becomeFirstResponder()
      case .OTPCode:
        vc.leftDividerView.backgroundColor = Theme.Divider.unselected
        vc.rightDividerView.backgroundColor = Theme.Divider.selected
        vc.emailButton.setTitleColor(Theme.Divider.unselectedText, for: .normal)
        vc.phoneButton.setTitleColor(Theme.Divider.selectedText, for: .normal)
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
