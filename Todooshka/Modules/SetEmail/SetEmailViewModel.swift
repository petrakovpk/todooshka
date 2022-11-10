//
//  SetEmailViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class SetEmailViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()
  let reload = BehaviorRelay<Void>(value: ())

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let currentEmailTextFieldText: Driver<String>
    let newEmailTextFieldText: Driver<String>
    let refreshButtonClickTrigger: Driver<Void>
    let sendVerificationEmailButtonClick: Driver<Void>
    let setNewEmailButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let emailLabelText: Driver<String>
    let emailTextFieldText: Driver<String>
    let navigateBack: Driver<Void>
    let sendEmailVerification: Driver<Void>
    let sendVerificationEmailButtonIsEnabled: Driver<Bool>
    let setNewEmailButtonIsEnabled: Driver<Bool>
    let setNewEmail: Driver<Void>
    let errorText: Driver<String>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let reload = reload.asDriver()

    let refresh = Driver.of(reload, input.refreshButtonClickTrigger).merge()

    let userStart = Driver<User?>
      .of(Auth.auth().currentUser)

    let userReload = refresh
      .map {
        Auth.auth().currentUser?.reload()
      }.map {
        Auth.auth().currentUser
      }

    let user = Driver
      .of(userStart, userReload)
      .merge()
      .compactMap { $0 }

    let email = user
      .compactMap { $0.email }

    let isEmailVerified = user
      .map { $0.isEmailVerified }

    let emailLabelText = isEmailVerified
      .map { $0 ? "Ваш основной email (подтвержден)" : "Ваш основной email (не подтвержден)" }

    let emailTextFieldText = email

    // IS VALID
    let isCurrentEmailValid = Driver.of(input.currentEmailTextFieldText, email)
      .merge()
      .map { email -> Bool in
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
      }

    let isNewEmailValid = input.newEmailTextFieldText
      .map { email -> Bool in
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
      }

    let sendEmailVerification = input.sendVerificationEmailButtonClick
      .withLatestFrom(isCurrentEmailValid) { $1 }
      .filter { $0 }
      .withLatestFrom(input.currentEmailTextFieldText) { $1 }
      .withLatestFrom(user) { ($0, $1) }.asObservable()
      .flatMapLatest { _, user -> Observable<Result<Void, Error>>  in
        user.rx.sendEmailVerification()
      }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let sendEmailVerificationError = sendEmailVerification
      .compactMap { result -> Error? in
        guard case .failure(let error) = result else { return nil }
        return error
      }

    let sendEmailVerificationSuccess = sendEmailVerification
      .compactMap { result -> Void? in
        guard case .success = result else { return nil }
        return ()
      }

    let sendVerificationEmailButtonIsEnabled = Driver
      .combineLatest(isEmailVerified, isCurrentEmailValid) { isEmailVerified, isCurrentEmailValid -> Bool in
        isEmailVerified == false && isCurrentEmailValid
      }

    let setNewEmailButtonIsEnabled = isNewEmailValid

    let setNewEmailTry = input.setNewEmailButtonClickTrigger
      .withLatestFrom(user) { $1 }
      .withLatestFrom(input.newEmailTextFieldText) { ($0, $1) }
      .asObservable()
      .flatMapLatest { user, email -> Observable<Result<Void, Error>>  in
        user.rx.updateEmail(to: email)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let setNewEmailTryError = setNewEmailTry
      .compactMap { result -> Error? in
        guard case .failure(let error) = result else { return nil }
        return error
      }

    let setNewEmail = setNewEmailTry
      .compactMap { result -> Void? in
        guard case .success = result else { return nil }
        return ()
      }.do { _ in self.reload.accept(()) }

    let navigateBack = input.backButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.navigateBack) }

    let setError = Driver
      .of(sendEmailVerificationError, setNewEmailTryError)
      .merge()
      .map { $0.localizedDescription }

    let clearEror = Driver
      .of(sendEmailVerificationSuccess, setNewEmail)
      .merge()
      .map { "" }

    let errorText = Driver
      .of(setError, clearEror)
      .merge()

    return Output(
      emailLabelText: emailLabelText,
      emailTextFieldText: emailTextFieldText,
      navigateBack: navigateBack,
      sendEmailVerification: sendEmailVerificationSuccess,
      sendVerificationEmailButtonIsEnabled: sendVerificationEmailButtonIsEnabled,
      setNewEmailButtonIsEnabled: setNewEmailButtonIsEnabled,
      setNewEmail: setNewEmail,
      errorText: errorText
    )
  }
}
