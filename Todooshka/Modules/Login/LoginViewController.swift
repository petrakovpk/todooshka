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
  
  fileprivate let emailTextField = TDAuthTextField(customPlaceholder: "Email", imageName: "sms")
  fileprivate let passwordTextField = TDAuthTextField(customPlaceholder: "Password", imageName: "lock")
  fileprivate let repeatPasswordTextField = TDAuthTextField(customPlaceholder: "Repeat Password", imageName: "lock")
  
  fileprivate let phoneTextField = TDAuthTextField(customPlaceholder: "Номер телефона", imageName: "call")
  fileprivate let OTPCodeTextField = TDAuthTextField(customPlaceholder: "SMS код", imageName: "lock")
  
  fileprivate let nextButton: UIButton = {
    let button = UIButton(type: .custom)
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
  
  let headerView = UIView()
  
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
    headerView.addSubview(backButton)
    
    // view
    view.backgroundColor = Theme.App.background
    
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
    emailTextField.returnKeyType = .done
    emailTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
    // passwordTextField
    passwordTextField.isSecureTextEntry = true
    passwordTextField.returnKeyType = .done
    passwordTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
    // phoneTextField
    phoneTextField.keyboardType = .numberPad
    phoneTextField.placeholder = "+X (XXX) XXX XX XX"
    phoneTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
    // codeTextField
    OTPCodeTextField.keyboardType = .numberPad
    OTPCodeTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
    // repeatPasswordTextField
    repeatPasswordTextField.isSecureTextEntry = true
    repeatPasswordTextField.returnKeyType = .done
    repeatPasswordTextField.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
    // nextButton
    nextButton.anchor(top: repeatPasswordTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 48)
    
    // errorTextView
    errorTextView.anchor(top: nextButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16,  heightConstant: 50)

    // ??
    emailTextField.isHidden = true
    passwordTextField.isHidden = true
    repeatPasswordTextField.isHidden = true
    phoneTextField.isHidden = true
    OTPCodeTextField.isHidden = true
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
      emailTextFieldDidEndEditing: emailTextField.rx.controlEvent(.editingDidEnd).asDriver() ,
      passwordTextFieldDidEndEditing: passwordTextField.rx.controlEvent(.editingDidEnd).asDriver(),
      repeatPasswordTextFieldDidEndEditing: repeatPasswordTextField.rx.controlEvent(.editingDidEnd).asDriver(),
      phoneTextFieldDidEndEditing: phoneTextField.rx.controlEvent(.editingDidEnd).asDriver(),
      OTPCodeTextFieldDidEndEditing: OTPCodeTextField.rx.controlEvent(.editingDidEnd).asDriver()
    )
    
    let output = viewModel.transform(input: input)
    
    [
      output.auth.drive(),
      output.correctPhoneFormat.drive(phoneTextField.rx.text),
      output.errorText.drive(errorTextView.rx.text),
      output.navigateBack.drive(),
      output.nextButtonIsEnabled.drive(setNextButtonIsEnabledBinder),
      output.sendEmailVerification.drive(),
      output.setLoginViewControllerStyle.drive(loginViewControllerStyleBinder),
      output.updateUserData.drive()
    ]
      .forEach{ $0.disposed(by: disposeBag) }
  }
  
  var setNextButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { (vc, isEnabled) in
      vc.nextButton.backgroundColor = isEnabled ? Palette.SingleColors.BlueRibbon : Palette.DualColors.Mischka_205_205_223_
      vc.nextButton.setTitleColor(isEnabled ? .white : Theme.App.text?.withAlphaComponent(0.12) , for: .normal)
      vc.nextButton.isEnabled = isEnabled
    })
  }
  
  var loginViewControllerStyleBinder: Binder<LoginViewControllerStyle> {
    return Binder(self, binding: { (vc, loginViewControllerStyle) in
      switch loginViewControllerStyle {
      case .Email:
        vc.leftDividerView.backgroundColor = Palette.SingleColors.BlueRibbon
        vc.rightDividerView.backgroundColor = Palette.DualColors.Mischka_205_205_223_
        vc.emailButton.setTitleColor(Theme.App.text, for: .normal)
        vc.phoneButton.setTitleColor(Palette.DualColors.Mischka_205_205_223_, for: .normal)
        vc.emailTextField.isHidden = false
        vc.phoneTextField.isHidden = true
        vc.passwordTextField.isHidden = true
        vc.repeatPasswordTextField.isHidden = true
        vc.OTPCodeTextField.isHidden = true
        vc.emailTextField.becomeFirstResponder()
      case .Password:
        vc.leftDividerView.backgroundColor = Palette.SingleColors.BlueRibbon
        vc.rightDividerView.backgroundColor = Palette.DualColors.Mischka_205_205_223_
        vc.emailButton.setTitleColor(Theme.App.text, for: .normal)
        vc.phoneButton.setTitleColor(Palette.DualColors.Mischka_205_205_223_, for: .normal)
        vc.emailTextField.isHidden = true
        vc.phoneTextField.isHidden = true
        vc.passwordTextField.isHidden = false
        vc.repeatPasswordTextField.isHidden = true
        vc.OTPCodeTextField.isHidden = true
        vc.passwordTextField.clear()
        vc.repeatPasswordTextField.clear()
        vc.passwordTextField.becomeFirstResponder()
      case .RepeatPassword:
        vc.leftDividerView.backgroundColor = Palette.SingleColors.BlueRibbon
        vc.rightDividerView.backgroundColor = Palette.DualColors.Mischka_205_205_223_
        vc.emailButton.setTitleColor(Theme.App.text, for: .normal)
        vc.phoneButton.setTitleColor(Palette.DualColors.Mischka_205_205_223_, for: .normal)
        vc.emailTextField.isHidden = true
        vc.phoneTextField.isHidden = true
        vc.passwordTextField.isHidden = false
        vc.repeatPasswordTextField.isHidden = false
        vc.OTPCodeTextField.isHidden = true
        vc.passwordTextField.clear()
        vc.repeatPasswordTextField.clear()
        vc.passwordTextField.becomeFirstResponder()
      case .Phone:
        vc.leftDividerView.backgroundColor = Palette.DualColors.Mischka_205_205_223_
        vc.rightDividerView.backgroundColor = Palette.SingleColors.BlueRibbon
        vc.emailButton.setTitleColor(Palette.DualColors.Mischka_205_205_223_, for: .normal)
        vc.phoneButton.setTitleColor(Theme.App.text, for: .normal)
        vc.emailTextField.isHidden = true
        vc.phoneTextField.isHidden = false
        vc.passwordTextField.isHidden = true
        vc.repeatPasswordTextField.isHidden = true
        vc.OTPCodeTextField.isHidden = true
        vc.phoneTextField.becomeFirstResponder()
      case .OTPCode:
        vc.leftDividerView.backgroundColor = Palette.DualColors.Mischka_205_205_223_
        vc.rightDividerView.backgroundColor = Palette.SingleColors.BlueRibbon
        vc.emailButton.setTitleColor(Palette.DualColors.Mischka_205_205_223_, for: .normal)
        vc.phoneButton.setTitleColor(Theme.App.text, for: .normal)
        vc.emailTextField.isHidden = true
        vc.phoneTextField.isHidden = true
        vc.passwordTextField.isHidden = true
        vc.repeatPasswordTextField.isHidden = true
        vc.OTPCodeTextField.isHidden = false
        vc.OTPCodeTextField.becomeFirstResponder()
      }
    })
  }
}
