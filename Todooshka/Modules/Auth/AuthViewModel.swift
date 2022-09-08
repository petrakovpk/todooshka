//
//  AuthViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 23.08.2021.
//

import AuthenticationServices
import Firebase
import GoogleSignIn
import RxCocoa
import RxFlow
import RxSwift

class AuthViewModel: Stepper {
  
  // MARK: - Properties
  let steps = PublishRelay<Step>()

  private let services: AppServices
  private let disposeBag = DisposeBag()
  
  struct Input {
    let appleButtonClickTrigger: Driver<Void>
    let createAccountButtonClickTrigger: Driver<Void>
    let googleButtonClickTrigger: Driver<UIViewController>
    let logInButtonClickTrigger: Driver<Void>
    let skipButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let authWithApple: Driver<String>
    let authWithGoogle: Driver<Void>
    let createAccount: Driver<Void>
    let logIn: Driver<Void>
    let skip: Driver<Void>
  }
  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let authWithApple = input.appleButtonClickTrigger
      .map { self.randomNonceString() }
    
    let authWithGoogle = input.googleButtonClickTrigger
      .map { viewController in
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { [unowned self] user, error in
          
          if let error = error {
            print(error.localizedDescription)
            return
          }
          
          guard let authentication = user?.authentication,
                let idToken = authentication.idToken else { return }
          
          let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
          
          logInWithCredential(credential: credential)
        }
      }
    
    let createAccount = input.createAccountButtonClickTrigger
      .map { self.steps.accept(AppStep.CreateAccountIsRequired) }
    
    let logIn = input.logInButtonClickTrigger
      .map { self.steps.accept(AppStep.LogInIsRequired) }
    
    let skip = input.skipButtonClickTrigger
      .map { self.steps.accept(AppStep.AuthIsCompleted) }
    
    return Output(
      authWithApple: authWithApple,
      authWithGoogle: authWithGoogle,
      createAccount: createAccount,
      logIn: logIn,
      skip: skip
    )
  }
  
  // MARK: - Handler
  func logInWithCredential(credential: AuthCredential) {
    services.authService.signInWithCredentials(credential: credential) { error in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      self.steps.accept(AppStep.AuthIsCompleted)
    }
  }
  
  //
  //    func loginButtonClick() {
  //        steps.accept(AppStep.CreateAccountIsRequired(isNewUser: false))
  //    }
  
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
}


