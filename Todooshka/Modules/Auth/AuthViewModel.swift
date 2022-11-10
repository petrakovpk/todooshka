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
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let credential = BehaviorRelay<AuthCredential?>(value: nil)

  private let services: AppServices
  private let disposeBag = DisposeBag()

  struct Input {
    let appleButtonClickTrigger: Driver<Void>
    let emailOrPhoneAccountButtonClickTrigger: Driver<Void>
    let googleButtonClickTrigger: Driver<UIViewController>
  //  let logInButtonClickTrigger: Driver<Void>
    let skipButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let appleGetNonceString: Driver<String>
    let auth: Driver<Void>
    let authWithEmailOrPhone: Driver<Void>
   // let logIn: Driver<Void>
    let skip: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let appleGetNonceString = input.appleButtonClickTrigger
      .map { self.randomNonceString() }

    // AUTH WITH APPLE
    let appleGetCredential = self.credential
      .asDriver()
      .compactMap { $0 }

    // AUTH WITH GOOGLE
    let authWithGoogle = input.googleButtonClickTrigger
      .compactMap { viewController -> AuthWithGoogleData? in
        guard let clientID = FirebaseApp.app()?.options.clientID else { return nil }
        return AuthWithGoogleData(viewController: viewController, config: GIDConfiguration(clientID: clientID))
      }.asObservable()
      .flatMapLatest { authWithGoogleData -> Observable<Result<GIDGoogleUser, Error>>  in
        GIDSignIn.sharedInstance.rx.signIn(with: authWithGoogleData.config, presenting: authWithGoogleData.viewController)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let googleGetCredential = authWithGoogle
      .compactMap { result -> GIDGoogleUser? in
        guard case .success(let user) = result else { return nil }
        return user
      }.compactMap { user -> AuthCredential? in
        guard let idToken = user.authentication.idToken else { return nil }
        return GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.authentication.accessToken)
      }

    let authWithCredentials = Driver
      .of(googleGetCredential, appleGetCredential)
      .merge()
      .asObservable()
      .flatMapLatest { credential ->  Observable<Result<AuthDataResult, Error>> in
        Auth.auth().rx.signInAndRetrieveData(with: credential)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let auth = authWithCredentials
      .compactMap { result -> AuthDataResult? in
        guard case .success(let authDataResult) = result else { return nil }
        return authDataResult
      }.do { _ in
        self.steps.accept(AppStep.authIsCompleted)
      }

    // UPDATE DATA
    let updateUserData = auth
      .asObservable()
      .flatMapLatest { authDataResult -> Observable<Result<DatabaseReference, Error>> in
        Database.database().reference().child("USERS").child(authDataResult.user.uid).rx.updateChildValues(
          ["email": authDataResult.user.email,
           "phoneNumber": authDataResult.user.phoneNumber,
           "displayName": authDataResult.user.displayName ]  )
      }.map { _ in () }
      .asDriver(onErrorJustReturn: ())

    let authWithEmailOrPhone = input.emailOrPhoneAccountButtonClickTrigger
      .map { self.steps.accept(AppStep.authWithEmailOrPhoneInIsRequired) }

    let skip = input.skipButtonClickTrigger
      .map { self.steps.accept(AppStep.authIsCompleted) }

    return Output(
      appleGetNonceString: appleGetNonceString,
      auth: updateUserData,
      authWithEmailOrPhone: authWithEmailOrPhone,
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
