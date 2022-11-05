//
//  LoginViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import GoogleSignIn
import Firebase

struct SignUpWithEmailAttr {
  let email: String
  let password: String
}

struct SignUpWithPhoneAttr {
  let verificationID: String
  let verificationCode: String
}

class LoginViewModel: Stepper {

  // MARK: - Properties
//  let isNewUser: Bool
  let services: AppServices
  let steps = PublishRelay<Step>()

  let loginViewControllerStyle = BehaviorRelay<LoginViewControllerStyle>(value: .email)

  // MARK: - Input
  struct Input {
    // prop
    let emailTextFieldText: Driver<String>
    let OTPCodeTextFieldText: Driver<String>
    let passwordTextFieldText: Driver<String>
    let phoneTextFieldText: Driver<String>
    let repeatPasswordTextFieldText: Driver<String>
    // actions
    let backButtonClickTrigger: Driver<Void>
    let emailButtonClickTrigger: Driver<Void>
    let nextButtonClickTrigger: Driver<Void>
    let phoneButtonClickTrigger: Driver<Void>
    let emailTextFieldDidEndEditing: Driver<Void>
    let passwordTextFieldDidEndEditing: Driver<Void>
    let repeatPasswordTextFieldDidEndEditing: Driver<Void>
    let phoneTextFieldDidEndEditing: Driver<Void>
    let OTPCodeTextFieldDidEndEditing: Driver<Void>
    let resetPasswordButtonClickTrigger: Driver<Void>
    let sendOTPCodeButtonClickTriger: Driver<Void>
  }

  struct Output {
    let auth: Driver<Void>
    let correctNumber: Driver<String>
    let errorText: Driver<String>
    let navigateBack: Driver<Void>
    let nextButtonIsEnabled: Driver<Bool>
    let sendEmailVerification: Driver<Result<Void, Error>>
    let setLoginViewControllerStyle: Driver<LoginViewControllerStyle>
    let setFocusOnRepeatPasswordTextField: Driver<Void>
    let updateUserData: Driver<Void>
    let setResetPasswordButtonClickSuccess: Driver<String>
    let setSendOTPCodeButtonClickSuccess: Driver<String>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  // swiftlint:disable cyclomatic_complexity
  func transform(input: Input) -> Output {

    let loginViewControllerStyle = loginViewControllerStyle.asDriver()

    // STYLE
    let next = Driver
      .of(
        input.nextButtonClickTrigger,
        input.emailTextFieldDidEndEditing,
        input.passwordTextFieldDidEndEditing
          .withLatestFrom(loginViewControllerStyle) { $1 }
          .filter { $0 == .password }
          .map { _ in () },
        input.repeatPasswordTextFieldDidEndEditing,
        input.phoneTextFieldDidEndEditing,
        input.OTPCodeTextFieldDidEndEditing
      ).merge()

    let setEmailStyle = input.emailButtonClickTrigger
      .map { LoginViewControllerStyle.email }

    let setPhoneStyle = input.phoneButtonClickTrigger
      .map {  LoginViewControllerStyle.phone }

    let setEmailOrPhoneStyleWithBack = input.backButtonClickTrigger
      .withLatestFrom(loginViewControllerStyle) { _, style -> LoginViewControllerStyle? in
        switch style {
        case .password, .repeatPassword: return .email
        case .otp: return .phone
        default: return nil
        }
      }.compactMap { $0 }
      .map { $0 }

    // CORRECT
    let correctNumber = input.phoneTextFieldText
      .map { phone -> String in
        let mask = "+X (XXX) XXX-XX-XX"
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
          if ch == "X" {
            // mask requires a number in this place, so take the next one
            result.append(numbers[index])

            // move numbers iterator to the next index
            index = numbers.index(after: index)

          } else {
            result.append(ch) // just append a mask character
          }
        }
        return result
      }

    // IS VALID
    let isEmailValid = input.emailTextFieldText
      .map { email -> Bool in
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
      }

    let isPhoneValid = correctNumber
      .map { $0.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression).count }
      .map { $0 == 11 }

    let isOTPCodeValid = input.OTPCodeTextFieldText
      .map { $0.isEmpty == false }

    let isPasswordValid = input.passwordTextFieldText
      .map { $0.count >= 8 }

    let isRepeatPasswordValid = input.repeatPasswordTextFieldText
      .withLatestFrom(input.passwordTextFieldText) { $0 == $1 && !$0.isEmpty }

    // NEXT BUTTON IS ENABLED
    let nextButtonIsEnabled = Driver
      .combineLatest(
        loginViewControllerStyle,
        isPhoneValid,
        isEmailValid,
        isPasswordValid,
        isRepeatPasswordValid,
        isOTPCodeValid
      ) { style, isPhoneValid, isEmailValid, isPasswordValid, isRepeatPasswordValid, isOTPCodeValid -> Bool in
        switch style {
        case .phone:
          return isPhoneValid
        case .email:
          return isEmailValid
        case .password:
          return isPasswordValid
        case .repeatPassword:
          return isPasswordValid && isRepeatPasswordValid
        case .otp:
          return isOTPCodeValid
        }
      }.distinctUntilChanged()

    // AUTH WITH EMAIL
    let signUpWithEmailAttr = Driver<SignUpWithEmailAttr>
      .combineLatest(input.emailTextFieldText, input.passwordTextFieldText) { SignUpWithEmailAttr(email: $0, password: $1) }

    let setPasswordOrRepeatPasswordStyle = next
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .email }
      .withLatestFrom(isEmailValid)
      .filter { $0 }
      .withLatestFrom(signUpWithEmailAttr)
      .asObservable()
      .flatMapLatest { attr -> Observable<[String]> in
        Auth.auth().rx.fetchProviders(forEmail: attr.email)
      }
      .asDriver(onErrorJustReturn: [])
      .map { providers -> LoginViewControllerStyle  in
        providers.isEmpty ? .repeatPassword : .password
      }

    // REGISTER

    let createUserWithEmail = next
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .repeatPassword }
      .withLatestFrom(isPasswordValid)
      .filter { $0 }
      .withLatestFrom(isRepeatPasswordValid)
      .filter { $0 }
      .withLatestFrom(signUpWithEmailAttr)
      .asObservable()
      .flatMapLatest { attr -> Observable<Result<AuthDataResult, Error>> in
        Auth.auth().rx.createUser(withEmail: attr.email, password: attr.password)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let sendEmailVerification = createUserWithEmail
      .compactMap { result -> AuthDataResult? in
        guard case .success(let authDataResult) = result else { return nil }
        return authDataResult
      }.asObservable()
      .flatMapLatest { result -> Observable<Result<Void, Error>> in
        result.user.rx.sendEmailVerification()
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let signUpWithEmail = createUserWithEmail
      .map { result -> Void in
        switch result {
        case .success: self.steps.accept(AppStep.authIsCompleted)
        default: return
        }
      }

    let signInWithEmailCheckUser = next
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .password}
      .withLatestFrom(signUpWithEmailAttr)
      .asObservable()
      .flatMapLatest { attr -> Observable<Result<AuthDataResult, Error>> in
        Auth.auth().rx.signIn(withEmail: attr.email, password: attr.password)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let signInWithEmail = signInWithEmailCheckUser
      .map { result -> Void in
        switch result {
        case .success: self.steps.accept(AppStep.authIsCompleted)
        default: return
        }
      }

    // AUTH WITH PHONE
    let setOTPCodeStyle = next
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .phone }
      .withLatestFrom(isPhoneValid)
      .filter { $0 }
      .map { _ in LoginViewControllerStyle.otp }

    let sendOTPCode = setOTPCodeStyle
      .withLatestFrom(input.phoneTextFieldText) {
        "+" + $1.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
      }.asObservable()
      .flatMapLatest { phone -> Observable<Result<String, Error>> in
        PhoneAuthProvider.provider().rx.verifyPhoneNumber(phone)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let sendOTPCodeWithButton = input.sendOTPCodeButtonClickTriger
      .withLatestFrom(input.phoneTextFieldText) {
        "+" + $1.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
      }.asObservable()
      .flatMapLatest { phone -> Observable<Result<String, Error>> in
        PhoneAuthProvider.provider().rx.verifyPhoneNumber(phone)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let setSendOTPCodeButtonClickSuccess = sendOTPCodeWithButton
      .compactMap { result -> String? in
        switch result {
        case .success: return "CМС с КОДОМ отправлено! Отправить повторно."
        case .failure: return nil
        }
      }.asDriver(onErrorJustReturn: "")

    let verificationID = sendOTPCode
      .compactMap { result -> String? in
        guard case .success(let verificationID) = result else { return nil }
        return verificationID
      }.asDriver(onErrorJustReturn: "")

    let signUpWithPhoneAttr = Driver
      .combineLatest(verificationID, input.OTPCodeTextFieldText) { SignUpWithPhoneAttr(verificationID: $0, verificationCode: $1) }

    let checkVerificationCode = next
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .otp }
      .withLatestFrom(isOTPCodeValid)
      .filter { $0 }
      .withLatestFrom(signUpWithPhoneAttr) {
        PhoneAuthProvider.provider().credential(withVerificationID: $1.verificationID, verificationCode: $1.verificationCode)
      }.asObservable()
      .flatMapLatest { credential -> Observable<Result<AuthDataResult, Error>>  in
        Auth.auth().rx.signInAndRetrieveData(with: credential)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let signInWithPhone = checkVerificationCode
      .map { result -> Void in
        switch result {
        case .success: self.steps.accept(AppStep.authIsCompleted)
        default: return
        }
      }

    // UPDATE DATA
    let updateUserData = Driver
      .of(createUserWithEmail, checkVerificationCode)
      .merge()
      .compactMap { result -> AuthDataResult? in
        guard case .success(let authDataResult) = result else { return nil }
        return authDataResult
      }.asObservable()
      .flatMapLatest { authDataResult -> Observable<Result<DatabaseReference, Error>> in
        Database.database().reference().child("USERS").child(authDataResult.user.uid).rx.updateChildValues(
          ["email": authDataResult.user.email,
           "phoneNumber": authDataResult.user.phoneNumber,
           "displayName": authDataResult.user.displayName ])
      }.map { _ in () }
      .asDriver(onErrorJustReturn: ())

    // AUT HANDLER
    let auth = Driver
      .of(
        signUpWithEmail,
        signInWithEmail,
        signInWithPhone
      ).merge()

    // RESET PASSWORD
    let resetPassword = input.resetPasswordButtonClickTrigger
      .withLatestFrom(signUpWithEmailAttr) { $1 }
      .asObservable()
      .flatMapLatest { attr ->  Observable<Result<Void, Error>>  in
        Auth.auth().rx.sendPasswordReset(withEmail: attr.email)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let setResetPasswordButtonClickSuccess = resetPassword
      .compactMap { result -> String? in
        switch result {
        case .success: return "Письмо отправлено! Отправить повторно."
        case .failure: return nil
        }
      }.asDriver()

    // STYLE HANDLER
    let setLoginViewControllerStyle = Driver.of(
      setEmailStyle,
      setPhoneStyle,
      setEmailOrPhoneStyleWithBack,
      setPasswordOrRepeatPasswordStyle,
      setOTPCodeStyle
    )
      .merge()
      .startWith(.email)
      .do { style in self.loginViewControllerStyle.accept(style) }

    // SET FOCUS ON REPEAT PASSWORD
    let setFocusOnRepeatPasswordTextField = input.passwordTextFieldDidEndEditing
      .withLatestFrom(loginViewControllerStyle) { $1 }
      .filter { $0 == .repeatPassword }
      .map { _ in () }
      .asDriver()

    // BACK
    let navigateBack = input.backButtonClickTrigger
      .withLatestFrom(loginViewControllerStyle) { _, style in
        if .phone == style || .email == style {
          self.steps.accept(AppStep.navigateBack)
        }
      }

    // ERROR
    let clearError = loginViewControllerStyle
      .map { _ -> String in "" }

    let errorTextCreateUserWithEmail = createUserWithEmail
      .map { result -> String in
        switch result {
        case .success: return ""
        case .failure(let error): return error.localizedDescription
        }
      }

    let errorTextUpdateUser = createUserWithEmail
      .map { result -> String in
        switch result {
        case .success: return ""
        case .failure(let error): return error.localizedDescription
        }
      }

    let errorTextSignInWithEmail = signInWithEmailCheckUser
      .map { result -> String in
        switch result {
        case .success: return ""
        case .failure(let error): return error.localizedDescription
        }
      }

    let resetPasswordError = resetPassword
      .map { result -> String in
        switch result {
        case .success: return ""
        case .failure(let error): return error.localizedDescription
        }
      }

    let errorTextSendingOTPCode = sendOTPCode
      .map { result -> String in
        switch result {
        case .success: return ""
        case .failure(let error): return error.localizedDescription
        }
      }.asDriver(onErrorJustReturn: "")

    let errorTextCheckOTPCode = checkVerificationCode
      .map { result -> String in
        switch result {
        case .success: return ""
        case .failure(let error): return error.localizedDescription
        }
      }.asDriver(onErrorJustReturn: "")

    let erroSendOTPCodeWithButton = sendOTPCodeWithButton
      .map { result -> String in
        switch result {
        case .success: return ""
        case .failure(let error): return error.localizedDescription
        }
      }.asDriver(onErrorJustReturn: "")

    let errorText = Driver
      .of( clearError,
           errorTextCreateUserWithEmail,
           errorTextSignInWithEmail,
           errorTextUpdateUser,
           errorTextSendingOTPCode,
           errorTextCheckOTPCode,
           resetPasswordError,
           erroSendOTPCodeWithButton
      ).merge()

    return Output(
      auth: auth,
      correctNumber: correctNumber,
      errorText: errorText,
      navigateBack: navigateBack,
      nextButtonIsEnabled: nextButtonIsEnabled,
      sendEmailVerification: sendEmailVerification,
      setLoginViewControllerStyle: setLoginViewControllerStyle,
      setFocusOnRepeatPasswordTextField: setFocusOnRepeatPasswordTextField,
      updateUserData: updateUserData,
      setResetPasswordButtonClickSuccess: setResetPasswordButtonClickSuccess,
      setSendOTPCodeButtonClickSuccess: setSendOTPCodeButtonClickSuccess
    )
  }
}
// swiftlint:enable cyclomatic_complexity
