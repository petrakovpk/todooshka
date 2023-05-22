//
//  ChangePasswordViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class ChangePasswordViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let passwordTextFieldText: Driver<String>
    let repeatPasswordTextFieldText: Driver<String>
    let setPasswordButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let errorText: Driver<String>
    let navigateBack: Driver<Void>
    let setPasswordButtonIsEnabled: Driver<Bool>
 //   let setPassword: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let errorTracker = ErrorTracker()
    let user = Driver<User?>.of(Auth.auth().currentUser)
      .compactMap { $0 }

    let passwordIsValid = input.passwordTextFieldText
      .map { $0.count >= 8 }

    let repeatPasswordIsValid = Driver
      .combineLatest(
        input.passwordTextFieldText,
        input.repeatPasswordTextFieldText,
        passwordIsValid
      ) { password, repeatPassword, passwordIsValid -> Bool in
        password == repeatPassword && passwordIsValid
      }

    let setPasswordButtonIsEnabled = repeatPasswordIsValid

    let setPassword = input.setPasswordButtonClickTrigger
      .withLatestFrom(repeatPasswordIsValid) { $1 }
      .filter { $0 }
      .withLatestFrom(input.repeatPasswordTextFieldText) { $1 }
      .withLatestFrom(user) { ($0, $1) }
      .asObservable()
      .flatMapLatest { password, user -> Observable<Void> in
        user.rx.updatePassword(to: password)
      }
      .trackError(errorTracker)

    let navigateBack = input.backButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.navigateBack) }

    let errorText = errorTracker
      .map { $0.localizedDescription }
      .asDriver()
    
    return Output(
      errorText: errorText,
      navigateBack: navigateBack,
      setPasswordButtonIsEnabled: setPasswordButtonIsEnabled
      //setPassword: setPasswordSuccess
    )
  }
}
