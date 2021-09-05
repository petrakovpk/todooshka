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
  lazy var headerLabel: UILabel = {
    let label = UILabel()
    label.text = "TODOOSHKA"
    label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    return label
  }()
  
  lazy var secondHeaderLabel: UILabel = {
    let label = UILabel()
    label.text = "Create an account"
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    return label
  }()
  
  lazy var errorLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.font = UIFont.systemFont(ofSize: 12, weight: .light)
    label.textColor = UIColor(red: 0.937, green: 0.408, blue: 0.322, alpha: 1)
    return label
  }()
  
  lazy var headerDescriptionTextView: UITextView = {
    let textView = UITextView()
    textView.text = "Brief description of onboarding that can be placed in two lines"
    textView.isScrollEnabled = false
    textView.isSelectable = false
    textView.isEditable = false
    textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    textView.textAlignment = .center
    return textView
  }()
  
  lazy var emailButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium) ])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  lazy var phoneButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Phone", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  lazy var emailTextField = TDAuthTextField(customPlaceholder: "Email", imageName: "sms")
  lazy var passwordTextField = TDAuthTextField(customPlaceholder: "Password", imageName: "lock")
  lazy var repeatPasswordTextField = TDAuthTextField(customPlaceholder: "Repeat Password", imageName: "lock")
  
  lazy var phoneTextField = TDAuthTextField(customPlaceholder: "Phone", imageName: "call")
  lazy var codeTextField = TDAuthTextField(customPlaceholder: "OTP Code", imageName: "lock")
  
  lazy var nextButton: UIButton = {
    let button = UIButton(type: .custom)
    button.cornerRadius = 48 / 2
    button.setTitle("Next", for: .normal)
    return button
  }()
  
  lazy var backButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    return button
  }()
  
  lazy var leftDividerView: UIView = {
    let view = UIView()
    return view
  }()
  
  lazy var rightDividerView: UIView = {
    let view = UIView()
    return view
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureUI()
    setViewColor() 
  }
  
  //MARK: - Configure UI
  func configureUI() {
    let headerView = UIView()
    
    view.addSubview(headerView)
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: 96)
    
    headerView.addSubview(backButton)
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    view.addSubview(headerLabel)
    headerLabel.anchor(top: view.topAnchor, topConstant: 84)
    headerLabel.anchorCenterXToSuperview()
    
    view.addSubview(secondHeaderLabel)
    secondHeaderLabel.anchor(top: headerLabel.bottomAnchor, topConstant: 31)
    secondHeaderLabel.anchorCenterXToSuperview()
    
    view.addSubview(headerDescriptionTextView)
    headerDescriptionTextView.anchor(top: secondHeaderLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 15, leftConstant: 29, rightConstant: 29)
    headerDescriptionTextView.anchorCenterXToSuperview()
    
    view.addSubview(emailButton)
    emailButton.anchor(top: headerDescriptionTextView.bottomAnchor, left: view.leftAnchor,  topConstant: 40, widthConstant: UIScreen.main.bounds.width / 2, heightConstant: 50)
    
    view.addSubview(phoneButton)
    phoneButton.anchor(top: headerDescriptionTextView.bottomAnchor, right: view.rightAnchor, topConstant: 40, widthConstant: UIScreen.main.bounds.width / 2, heightConstant: 50)
    
    view.addSubview(leftDividerView)
    leftDividerView.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: emailButton.rightAnchor, heightConstant: 1)
    
    view.addSubview(rightDividerView)
    rightDividerView.anchor(top: phoneButton.bottomAnchor, left: phoneButton.leftAnchor, right: view.rightAnchor, heightConstant: 1)
    
    view.addSubview(emailTextField)
    emailTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 45, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
    view.addSubview(passwordTextField)
    passwordTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 45, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
    view.addSubview(phoneTextField)
    phoneTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 45, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
    view.addSubview(codeTextField)
    codeTextField.anchor(top: emailButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 45, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
    view.addSubview(nextButton)
    nextButton.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 48)
    
    view.addSubview(repeatPasswordTextField)
    repeatPasswordTextField.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
    view.addSubview(errorLabel)
    errorLabel.anchor(top: leftDividerView.bottomAnchor, left: view.leftAnchor, bottom: emailTextField.topAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16)
    
    emailTextField.becomeFirstResponder()
    
    emailTextField.isHidden = false
    passwordTextField.isHidden = true
    repeatPasswordTextField.isHidden = true
    phoneTextField.isHidden = true
    codeTextField.isHidden = true
    
    passwordTextField.isSecureTextEntry = true
    repeatPasswordTextField.isSecureTextEntry = true
    
    emailTextField.returnKeyType = .done
    passwordTextField.returnKeyType = .done
    repeatPasswordTextField.returnKeyType = .done
    
    phoneTextField.keyboardType = .numberPad
    codeTextField.keyboardType = .numberPad
    
    phoneTextField.placeholder = "+X (XXX) XXX XX XX"
  }
  
  //MARK: - Set Next Button
  func setEnabledNextButton() {
    nextButton.backgroundColor = .blueRibbon
    nextButton.setTitleColor(.white, for: .normal)
    nextButton.isEnabled = true
  }
  
  func setDisabledNextButton() {
    nextButton.backgroundColor = UIColor(named: "authDisablesNextButtonBackground")
    nextButton.setTitleColor(UIColor(named: "authDisablesNextButtonText")!.withAlphaComponent(0.12) , for: .normal)
    nextButton.isEnabled = false
  }
  
  //MARK: - Set Login Mode
  func setPhoneMode() {
    if phoneTextField.isHidden == true,
       codeTextField.isHidden == true {
      
      emailTextField.isHidden = true
      passwordTextField.isHidden = true
      if repeatPasswordTextField.isHidden == false {
        self.nextButton.removeAllConstraints()
        self.nextButton.anchor(top: self.emailTextField.bottomAnchor, left: self.view.leftAnchor, right: self.view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 48)
        
        repeatPasswordTextField.isHidden = true
        
        UIView.animate(withDuration: 0.2) {
          self.view.layoutIfNeeded()
        }
        
      }
      
      phoneTextField.isHidden = false
      codeTextField.isHidden = true
      
      emailTextField.clear()
      passwordTextField.clear()
      repeatPasswordTextField.clear()
      
      phoneTextField.clear()
      codeTextField.clear()
      
      emailButton.setTitleColor(UIColor(named: "authModeButtonTextDisable"), for: .normal)
      phoneButton.setTitleColor(UIColor(named: "appText"), for: .normal)
      
      leftDividerView.backgroundColor = UIColor(named: "authDivider")
      rightDividerView.backgroundColor = UIColor.blueRibbon
      
      phoneTextField.becomeFirstResponder()
    }
    
    if codeTextField.isHidden == false {
      phoneTextField.isHidden = false
      codeTextField.isHidden = true
      phoneTextField.becomeFirstResponder()
      
      codeTextField.clear()
    }
  }
  
  func setCodeMode() {
    if phoneTextField.isHidden == false {
      phoneTextField.isHidden = true
      codeTextField.isHidden = false
      codeTextField.becomeFirstResponder()
    }
  }
  
  func setEmailMode() {
    if emailTextField.isHidden == true,
       passwordTextField.isHidden == true {
      emailTextField.isHidden = false
      passwordTextField.isHidden = true
      repeatPasswordTextField.isHidden = true
      
      phoneTextField.isHidden = true
      codeTextField.isHidden = true
      
      emailTextField.clear()
      passwordTextField.clear()
      repeatPasswordTextField.clear()
      
      phoneTextField.clear()
      codeTextField.clear()
      
      emailButton.setTitleColor(UIColor(named: "appText"), for: .normal)
      phoneButton.setTitleColor(UIColor(named: "authModeButtonTextDisable"), for: .normal)
      
      leftDividerView.backgroundColor = UIColor.blueRibbon
      rightDividerView.backgroundColor = UIColor(named: "authDivider")
      
      emailTextField.becomeFirstResponder()
    }
    
    if repeatPasswordTextField.isHidden == false {
      nextButton.removeAllConstraints()
      nextButton.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 48)
      
      repeatPasswordTextField.clear()
      passwordTextField.clear()
      
      passwordTextField.isHidden = true
      repeatPasswordTextField.isHidden = true
      emailTextField.isHidden = false
      emailTextField.becomeFirstResponder()
      
      UIView.animate(withDuration: 0.2) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
  func setPasswordMode() {
    if emailTextField.isHidden == false {
      
      self.emailTextField.isHidden = true
      self.passwordTextField.isHidden = false
      self.passwordTextField.becomeFirstResponder()
      
      if viewModel.isNewUser {
        
        self.nextButton.removeAllConstraints()
        self.nextButton.anchor(top: self.repeatPasswordTextField.bottomAnchor, left: self.view.leftAnchor, right: self.view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 48)
        
        UIView.animate(withDuration: 0.2) {
          self.view.layoutIfNeeded()
        } completion: { result in
          self.repeatPasswordTextField.isHidden = false
        }
      }
    }
  }
  
  //MARK: - Bind
  func bindTo(with viewModel: LoginViewModel) {
    self.viewModel = viewModel
    
    //MARK: - Bind Inputs
    phoneButton.rx.tap.bind{ viewModel.phoneButtonClick() }.disposed(by: disposeBag)
    emailButton.rx.tap.bind{ viewModel.emailButtonClick() }.disposed(by: disposeBag)
    nextButton.rx.tap.bind{ viewModel.nextButtonClick() }.disposed(by: disposeBag)
    backButton.rx.tap.bind{ viewModel.backButtonClick() }.disposed(by: disposeBag)
    
    
    emailTextField.rx.text.orEmpty.bind(to: viewModel.emailTextFieldInput).disposed(by: disposeBag)
    passwordTextField.rx.text.orEmpty.bind(to: viewModel.passwordTextFieldInput).disposed(by: disposeBag)
    repeatPasswordTextField.rx.text.orEmpty.bind(to: viewModel.repeatPasswordTextFieldInput).disposed(by: disposeBag)
    phoneTextField.rx.text.orEmpty.bind(to: viewModel.phoneTextFieldInput).disposed(by: disposeBag)
    codeTextField.rx.text.orEmpty.bind(to: viewModel.codeTextFieldInput).disposed(by: disposeBag)
    
    emailTextField.rx.controlEvent(.editingDidEndOnExit).bind{ viewModel.nextButtonClick() }.disposed(by: disposeBag)
    passwordTextField.rx.controlEvent(.editingDidEndOnExit).bind{ self.repeatPasswordTextField.becomeFirstResponder() }.disposed(by: disposeBag)
    repeatPasswordTextField.rx.controlEvent(.editingDidEndOnExit).bind{ viewModel.nextButtonClick() }.disposed(by: disposeBag)
    
    //MARK: - Bind Outputs
    viewModel.nextButtonIsEnabledOutput.bind{ $0 ? self.setEnabledNextButton() : self.setDisabledNextButton() }.disposed(by: disposeBag)
    viewModel.phoneTextFieldOutput.bind(to: phoneTextField.rx.text).disposed(by: disposeBag)
    viewModel.errorTextFieldOutput.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
    
    viewModel.loginModeOutput.bind{[weak self] mode in
      guard let self = self else { return }
      switch mode {
      case .email:
        self.setEmailMode()
      case .phone:
        self.setPhoneMode()
      case .password:
        self.setPasswordMode()
      case .code:
        self.setCodeMode()
      }
    }.disposed(by: disposeBag)
  }
  
 
}


