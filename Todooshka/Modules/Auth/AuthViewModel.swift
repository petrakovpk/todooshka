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

struct AuthWithGoogleData {
  let viewController: UIViewController
  let config: GIDConfiguration
}

class AuthViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let credential = PublishRelay<AuthCredential>()
  
  private let services: AppServices
  private let disposeBag = DisposeBag()
  
  struct Input {
    let emailOrPhoneAccountButtonClickTrigger: Driver<Void>
    let appleButtonClickTrigger: Driver<Void>
    let googleButtonClickTrigger: Driver<UIViewController>
    let skipButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let authWithEmailOrPhone: Driver<AppStep>
    let appleAskForAuthRequest: Driver<String>
    let auth: Driver<AuthDataResult>
    let skip: Driver<AppStep>
  }
  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    let errorTracker = ErrorTracker()
    
    // Auth with Email or Phone
    let authWithEmailOrPhone = input.emailOrPhoneAccountButtonClickTrigger
      .map { _ -> AppStep in
        AppStep.authWithEmailOrPhoneInIsRequired
      }
      .do { step in
        self.steps.accept(step)
      }
    
    // Auth with apple
    let appleGetCredential = credential
      .asDriverOnErrorJustComplete()
    
    let appleAskForAuthRequest = input.appleButtonClickTrigger
      .map { _ -> String in
        self.randomNonceString()
      }
    
    // Auth with google
    let signInWithGoogle = input.googleButtonClickTrigger
      .flatMapLatest { viewController -> Driver<GIDSignInResult> in
        GIDSignIn.sharedInstance.rx
          .signIn(with: viewController)
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }
    
    let googleGetCredentials = signInWithGoogle
      .compactMap { result -> AuthCredential? in
        if let idToken = result.user.idToken {
          return GoogleAuthProvider.credential(
            withIDToken: idToken.tokenString,
            accessToken: result.user.accessToken .tokenString)
        } else {
          return nil
        }
      }
    
    let auth = Driver.of(appleGetCredential, googleGetCredentials)
      .merge()
      .flatMapLatest { credential -> Driver<AuthDataResult> in
        Auth.auth().rx
          .signInAndRetrieveData(with: credential)
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }
      .do { authDataResult in
        self.steps.accept(AppStep.authIsCompleted)
      }
    
      
    let skip = input.skipButtonClickTrigger
      .map { _ -> AppStep in
        AppStep.authIsCompleted
      }
      .do { step in
        self.steps.accept(step)
      }
  
    
    return Output(
      authWithEmailOrPhone: authWithEmailOrPhone,
      appleAskForAuthRequest: appleAskForAuthRequest,
      auth: auth,
      skip: skip
    )
  }
  
  // MARK: - Helpers
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
