//
//  AuthViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 23.08.2021.
//

import UIKit

import RxSwift
import RxCocoa

import Firebase
import AuthenticationServices
import CryptoKit

class AuthViewController: UIViewController {
    
    //MARK: - Properties
    var viewModel: AuthViewModel!
    private let disposeBag = DisposeBag()
    
    private var currentNonce: String?
    
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
    
    lazy var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.setTitleColor(UIColor(red: 0.039, green: 0.047, blue: 0.137, alpha: 1), for: .normal)
        
        let attrString = NSAttributedString(string: "Create with email or phone", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        button.setAttributedTitle(attrString, for: .normal)
        return button
    }()
    
    lazy var appleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(red: 0.128, green: 0.13, blue: 0.154, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        
        let attrString = NSAttributedString(string: "Continue with Apple", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        button.setAttributedTitle(attrString, for: .normal)
        return button
    }()
    
    lazy var googleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(red: 0.937, green: 0.408, blue: 0.322, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        
        let attrString = NSAttributedString(string: "Continue with Google", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        button.setAttributedTitle(attrString, for: .normal)
        return button
    }()
    
    lazy var skipButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(red: 0.583, green: 0.592, blue: 0.696, alpha: 1), for: .normal)
        
        let attrString = NSAttributedString(string: "or skip registration", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        button.setAttributedTitle(attrString, for: .normal)
        return button
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.setTitleColor(UIColor(red: 0.039, green: 0.047, blue: 0.137, alpha: 1), for: .normal)
        
        let attrString = NSAttributedString(string: "Log in", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)])
        button.setAttributedTitle(attrString, for: .normal)
        return button
    }()
    
    lazy var privacyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(red: 0.583, green: 0.592, blue: 0.696, alpha: 1), for: .normal)
        
        let attrString = NSAttributedString(string: "Privacy & Terms", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        button.setAttributedTitle(attrString, for: .normal)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        configureUI()
        setViewColor()
    }
    
    //MARK: - Configure UI
    func configureUI() {
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
    func bindTo(with viewModel: AuthViewModel) {
        self.viewModel = viewModel
        
        createButton.rx.tap.bind{ viewModel.createButtonClick() }.disposed(by: disposeBag)
        appleButton.rx.tap.bind { self.startSignInWithAppleFlow() }.disposed(by: disposeBag)
        googleButton.rx.tap.bind { viewModel.googleButtonClick(viewController: self) }.disposed(by: disposeBag)
        skipButton.rx.tap.bind{ viewModel.skipButtonClick() }.disposed(by: disposeBag)
        loginButton.rx.tap.bind{ viewModel.loginButtonClick() }.disposed(by: disposeBag)
    }
}

//MARK: - Apple Sign In delegate
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
            viewModel.logInWithCredential(credential: credential)
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
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
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
