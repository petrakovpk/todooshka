//
//  AuthViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 23.08.2021.
//

import AuthenticationServices
import CryptoKit
import Firebase
import RxCocoa
import RxSwift
import UIKit

class AuthViewController: UIViewController {
  
  // MARK: - Public
  var viewModel: AuthViewModel!
  
  //MARK: - Private
  private let disposeBag = DisposeBag()
  private var currentNonce: String?
  
  //MARK: - UI Elements
  private let headerLabel: UILabel = {
    let label = UILabel()
    label.text = "TODOOSHKA"
    label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    label.textColor = Style.App.text
    return label
  }()
  
  private let secondHeaderLabel: UILabel = {
    let label = UILabel()
    label.text = "Войдите в аккаунт"
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    label.textColor = Style.App.text
    return label
  }()
  
  private let headerDescriptionTextView: UITextView = {
    let textView = UITextView()
    textView.text = "Авторизация позволит вам сохранять задачи в облаке"
    textView.isScrollEnabled = false
    textView.isSelectable = false
    textView.isEditable = false
    textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    textView.textAlignment = .center
    textView.backgroundColor = .clear
    textView.textColor = Palette.SingleColors.SantasGray
    return textView
  }()
  
  private let emailOrPhoneAccountButton: UIButton = {
    let button = UIButton(type: .custom)
    button.cornerRadius = 25
    button.backgroundColor = .white
    button.setTitleColor(UIColor(red: 0.039, green: 0.047, blue: 0.137, alpha: 1), for: .normal)
    let attrString = NSAttributedString(string: "Войти через почту / телефон", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  private let appleButton: UIButton = {
    let button = UIButton(type: .custom)
    button.cornerRadius = 25
    button.backgroundColor = UIColor(red: 0.128, green: 0.13, blue: 0.154, alpha: 1)
    button.setTitleColor(.white, for: .normal)
    let attrString = NSAttributedString(string: "Продолжить с Apple", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  private let googleButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(red: 0.937, green: 0.408, blue: 0.322, alpha: 1)
    button.setTitleColor(.white, for: .normal)
    button.cornerRadius = 25
    let attrString = NSAttributedString(string: "Продолжить с Google", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  private let skipButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitleColor(UIColor(red: 0.583, green: 0.592, blue: 0.696, alpha: 1), for: .normal)
    let attrString = NSAttributedString(string: "Продолжить без регистрации", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
    button.setAttributedTitle(attrString, for: .normal)
    return button
  }()
  
  private let privacyButton: UIButton = {
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
    
    // adding
    view.addSubview(headerLabel)
    view.addSubview(secondHeaderLabel)
    view.addSubview(headerDescriptionTextView)
    view.addSubview(emailOrPhoneAccountButton)
    view.addSubview(appleButton)
    view.addSubview(googleButton)
    view.addSubview(skipButton)
    
    // view
    view.backgroundColor = Style.Auth.Background
    
    // headerLabel
    headerLabel.anchor(top: view.topAnchor, topConstant: 84)
    headerLabel.anchorCenterXToSuperview()
    
    // secondHeaderLabel
    secondHeaderLabel.anchor(top: headerLabel.bottomAnchor, topConstant: 31)
    secondHeaderLabel.anchorCenterXToSuperview()
    
    // headerDescriptionTextView
    headerDescriptionTextView.anchor(top: secondHeaderLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 15, leftConstant: 29, rightConstant: 29)
    headerDescriptionTextView.anchorCenterXToSuperview()
    
    // createButton
    emailOrPhoneAccountButton.anchor(top: headerDescriptionTextView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 71, leftConstant: 16, rightConstant: 16, heightConstant: 50)
    
    // appleButton
    appleButton.anchor(top: emailOrPhoneAccountButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 50)
    
    // googleButton
    googleButton.anchor(top: appleButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 12, leftConstant: 16, rightConstant: 16, heightConstant: 50)
    
    // skipButton
    skipButton.anchor(top: googleButton.bottomAnchor, topConstant: 25)
    skipButton.anchorCenterXToSuperview()

  }
  
  //MARK: - Bind
  func bindViewModel() {
    
    let input = AuthViewModel.Input(
      appleButtonClickTrigger: appleButton.rx.tap.asDriver(),
      emailOrPhoneAccountButtonClickTrigger: emailOrPhoneAccountButton.rx.tap.asDriver(),
      googleButtonClickTrigger: googleButton.rx.tap.asDriver().map { _ in self },
      skipButtonClickTrigger: skipButton.rx.tap.asDriver()
    )
    
    let output = viewModel.transform(input: input)
    
    [
      output.appleGetNonceString.drive(signInWithAppleBinder),
      output.auth.drive(),
      output.authWithEmailOrPhone.drive(),
      output.skip.drive()
    ]
      .forEach{ $0.disposed(by: disposeBag) }
  }
  
  var signInWithAppleBinder: Binder<String> {
    return Binder(self, binding: { (vc, currentNonce) in
      vc.currentNonce = currentNonce
      
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = self.sha256(currentNonce)
      
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      
      // self
      authorizationController.performRequests()
      
    })
  }
  
  @available(iOS 13, *)
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      return String(format: "%02x", $0)
    }.joined()
    
    return hashString
  }
  
}

// MARK: - Apple Sign In delegate
@available(iOS 13.0, *)
extension AuthViewController: ASAuthorizationControllerDelegate {
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential.
      let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
      // Sign in with Firebase.
      viewModel.credential.accept(credential)
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
  }
}
