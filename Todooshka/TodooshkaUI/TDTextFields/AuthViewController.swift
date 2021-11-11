//
//  AuthViewController.swift
//  Whassupp
//
//  Created by Петраков Павел Константинович on 01.11.2021.
//

import UIKit
import RxSwift
import RxCocoa

class AuthViewController: UIViewController {
  
  //MARK: - Properties
  var viewModel: AuthViewModel!
  private let disposeBag = DisposeBag()
  
  //MARK: - UI Elements
  lazy var headerLabel: UILabel = {
    let label = UILabel()
    label.text = "WHASSUPP"
    label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    label.textColor = UIColor(named: "text")
    return label
  }()
  
  lazy var secondHeaderLabel: UILabel = {
    let label = UILabel()
    label.text = "Войдите в аккаунт"
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    label.textColor = UIColor(named: "text")
    return label
  }()
  
  lazy var headerDescriptionTextView: UITextView = {
    let textView = UITextView()
    //textView.text = "Brief description of onboarding that can be placed in two lines"
    textView.isScrollEnabled = false
    textView.isSelectable = false
    textView.isEditable = false
    textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    textView.textAlignment = .center
    textView.backgroundColor = .clear
    textView.textColor = UIColor(named: "santasGray")
    return textView
  }()
  
  lazy var createButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = .white
    button.setTitleColor(UIColor(red: 0.039, green: 0.047, blue: 0.137, alpha: 1), for: .normal)
    
    let attrString = NSAttributedString(string: "Создать аккаунт через почту / телефон", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  lazy var appleButton: AppleSignInButton = {
    let button = AppleSignInButton(type: .custom)
    button.backgroundColor = UIColor(red: 0.128, green: 0.13, blue: 0.154, alpha: 1)
    button.setTitleColor(.white, for: .normal)
    
    let attrString = NSAttributedString(string: "Продолжить с Apple", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button 
  }()
  
  lazy var googleButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(red: 0.937, green: 0.408, blue: 0.322, alpha: 1)
    button.setTitleColor(.white, for: .normal)
    
    let attrString = NSAttributedString(string: "Продолжить с Google", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  lazy var skipButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitleColor(UIColor(red: 0.583, green: 0.592, blue: 0.696, alpha: 1), for: .normal)
    
    let attrString = NSAttributedString(string: "пропустить регистрацию", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  lazy var loginButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = .white
    button.setTitleColor(UIColor(red: 0.039, green: 0.047, blue: 0.137, alpha: 1), for: .normal)
    
    let attrString = NSAttributedString(string: "Войти в аккаунт через почту / телефон", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  lazy var privacyButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitleColor(UIColor(red: 0.583, green: 0.592, blue: 0.696, alpha: 1), for: .normal)
    
    let attrString = NSAttributedString(string: "Правила и условия", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureUI()
    bindViewModel()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    view.backgroundColor = UIColor(named: "backgroundColor")
    
    view.addSubview(headerLabel)
    headerLabel.anchor(top: view.topAnchor, topConstant: 84)
    headerLabel.anchorCenterXToSuperview()
    
    view.addSubview(secondHeaderLabel)
    secondHeaderLabel.anchor(top: headerLabel.bottomAnchor, topConstant: 31)
    secondHeaderLabel.anchorCenterXToSuperview()
    
    view.addSubview(headerDescriptionTextView)
    headerDescriptionTextView.anchor(top: secondHeaderLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 15, leftConstant: 29, rightConstant: 29)
    headerDescriptionTextView.anchorCenterXToSuperview()
    
    createButton.cornerRadius = 25
    view.addSubview(createButton)
    createButton.anchor(top: headerDescriptionTextView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 71, leftConstant: 16, rightConstant: 16, heightConstant: 50)
    
    appleButton.cornerRadius = 25
    view.addSubview(appleButton)
    appleButton.anchor(top: createButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 50)
    
    googleButton.cornerRadius = 25
    view.addSubview(googleButton)
    googleButton.anchor(top: appleButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 50)
    
    view.addSubview(skipButton)
    skipButton.anchor(top: googleButton.bottomAnchor, topConstant: 25)
    skipButton.anchorCenterXToSuperview()
    
    loginButton.cornerRadius = 25
    view.addSubview(loginButton)
    loginButton.anchor(top: skipButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 60, leftConstant: 16, rightConstant: 16, heightConstant: 50)
    
    view.addSubview(privacyButton)
    privacyButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, bottomConstant: 20)
    privacyButton.anchorCenterXToSuperview()
  }
  
  //MARK: - Bind
  func bindViewModel() {
    
    let input = AuthViewModel.Input(
      createButtonClickTrigger: createButton.rx.tap.asDriver(),
      appleButtonClickTrigger: appleButton.rx.loginOnTap(scope: [.fullName, .email]).asDriver(onErrorJustReturn: (nil, nil)),
      googleButtonClickTrigger: googleButton.rx.tap.map{ return self }.asDriver(onErrorJustReturn: self),
      skipButtonClickTrigger: skipButton.rx.tap.asDriver(),
      loginButtonClickTrigger: loginButton.rx.tap.asDriver()
    )
    
    let output = viewModel.transform(input: input)
    
    output.createButtonClick.drive().disposed(by: disposeBag)
    output.appleButtonClick.drive().disposed(by: disposeBag)
    output.googleButtonClick.drive().disposed(by: disposeBag)
    output.skipButtonlLick.drive().disposed(by: disposeBag)
    output.loginButtonClick.drive().disposed(by: disposeBag)
  }
}
