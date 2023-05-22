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

class LoginViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let loginViewControllerStyle = BehaviorRelay<LoginViewControllerStyle>(value: .email)
  
  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    // buttons
    let emailButtonClickTrigger: Driver<Void>
    let phoneButtonClickTrigger: Driver<Void>
    // text fields - 1st screen
    let emailTextFieldText: Driver<String>
    let phoneTextFieldText: Driver<String>
    // text fields - 1st screen events
    let emailTextFieldDidEndEditing: Driver<Void>
    let phoneTextFieldDidEndEditing: Driver<Void>
    // text fields - 2nd screen
    let passwordTextFieldText: Driver<String>
    let repeatPasswordTextFieldText: Driver<String>
    let OTPCodeTextFieldText: Driver<String>
    // text fields - 2nd screen - events
    let passwordTextFieldDidEndEditing: Driver<Void>
    let repeatPasswordTextFieldDidEndEditing: Driver<Void>
    let OTPCodeTextFieldDidEndEditing: Driver<Void>
    // next button
    let nextButtonClickTrigger: Driver<Void>
    // bottom buttons
    let resetPasswordButtonClickTrigger: Driver<Void>
    let sendOTPCodeButtonClickTriger: Driver<Void>
  }
  
  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    // style
    let loginViewControllerStyle: Driver<LoginViewControllerStyle>
    let loginViewControllerStyleHandler: Driver<Void>
    // email
    let sendEmailVerification: Driver<Void>
    // phone
    let phoneNumberTextField: Driver<String>
    // repeat password
    let setFocusOnRepeatPasswordTextField: Driver<Void>
    // next button
    let nextButtonIsEnabled: Driver<Bool>
    // auth
    let auth: Driver<AppStep>
    // error
    let errorText: Driver<String>
    
//
//    // let updateUserData: Driver<Void>
//    let setResetPasswordButtonClickSuccess: Driver<Void>
//    let setSendOTPCodeButtonClickSuccess: Driver<String>
  }
  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  // swiftlint:disable cyclomatic_complexity
  func transform(input: Input) -> Output {
    let errorTracker = ErrorTracker()
    let loginViewControllerStyle = loginViewControllerStyle.asDriver().debug()
    
    // MARK: Style - Email
    let setEmailStyleTrigger1 = input.emailButtonClickTrigger
    
    let setEmailStyleTrigger2 = input.backButtonClickTrigger
      .withLatestFrom(loginViewControllerStyle)
      .filter { style -> Bool in
        (style == .password) || (style == .repeatPassword)
      }
      .mapToVoid()
    
    let setEmailStyle = Driver.of(setEmailStyleTrigger1, setEmailStyleTrigger2)
      .merge()
      .map { _ -> LoginViewControllerStyle in
        .email
      }
    
    let isEmailValid = input.emailTextFieldText
      .map { email -> Bool in
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
      }
    
    let signInMethods = Driver.of(input.nextButtonClickTrigger, input.emailTextFieldDidEndEditing)
      .merge()
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .email }
      .withLatestFrom(isEmailValid)
      .filter { $0 }
      .withLatestFrom(input.emailTextFieldText)
      .flatMapLatest { email -> Driver<[String]> in
        Auth.auth().rx
          .fetchSignInMethods(forEmail: email)
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }
    
    let setPasswordStyle = signInMethods
      .filter { !$0.isEmpty }
      .map { _ -> LoginViewControllerStyle in
          .password
      }
    
    let setRepeatPasswordStyle = signInMethods
      .filter { $0.isEmpty }
      .map { _ -> LoginViewControllerStyle in
          .repeatPassword
      }
  
    // MARK: Style - Password
    let isPasswordValid = input.passwordTextFieldText
      .map { $0.count >= 8 }
    
    let signInWithEmail = Driver
      .of(input.nextButtonClickTrigger, input.passwordTextFieldDidEndEditing)
      .merge()
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .password }
      .withLatestFrom(isPasswordValid)
      .filter { $0 }
      .withLatestFrom(input.emailTextFieldText)
      .withLatestFrom(input.passwordTextFieldText) { (email: $0, password: $1) }
      .debug()
      .flatMapLatest { (email, password) -> Driver<AuthDataResult> in
        Auth.auth().rx
          .signIn(withEmail: email, password: password)
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }


    // MARK: Style - Repeat Password
    let isRepeatPasswordValid = input.repeatPasswordTextFieldText
      .withLatestFrom(input.passwordTextFieldText) { $0 == $1 && !$0.isEmpty }
    
    let signUpWithEmail = Driver
      .of(input.nextButtonClickTrigger, input.passwordTextFieldDidEndEditing)
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .repeatPassword }
      .withLatestFrom(isPasswordValid)
      .filter { $0 }
      .withLatestFrom(isRepeatPasswordValid)
      .filter { $0 }
      .withLatestFrom(input.emailTextFieldText)
      .withLatestFrom(input.passwordTextFieldText) { (email: $0, password: $1) }
      .flatMapLatest { (email, password) -> Driver<AuthDataResult> in
        Auth.auth().rx
          .signIn(withEmail: email, password: password)
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }
    
    // Set focus on repeat password
    let setFocusOnRepeatPasswordTextField = input.passwordTextFieldDidEndEditing
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .repeatPassword }
      .mapToVoid()
      .asDriver()
    
    let sendEmailVerification = signUpWithEmail
      .flatMapLatest { result -> Driver<Void> in
        result.user.rx
          .sendEmailVerification()
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }
     
    // MARK: Style - Phone
    let setPhoneStyleTrigger1 = input.phoneButtonClickTrigger
    
    let setPhoneStyleTrigger2 = input.backButtonClickTrigger
      .withLatestFrom(loginViewControllerStyle)
      .filter { style -> Bool in
        style == .otp
      }
      .mapToVoid()

    let setPhoneStyle = Driver.of(setPhoneStyleTrigger1, setPhoneStyleTrigger2)
      .merge()
      .map { _ -> LoginViewControllerStyle in
        .phone
      }
    
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

    let isPhoneValid = correctNumber
      .map { $0.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression).count }
      .map { $0 == 11 }
    
    // MARK: - Style - OTP Code
    let setOtpStyleTrigger = Driver.of(input.phoneTextFieldDidEndEditing, input.nextButtonClickTrigger)
      .merge()
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .phone }
      .withLatestFrom(isPhoneValid)
      .filter { $0 }
    
    let setOtpStyle = setOtpStyleTrigger
      .map { _ -> LoginViewControllerStyle in
          .otp
      }
    
    let sendOtpCode = Driver
      .of(setOtpStyle.mapToVoid(), input.sendOTPCodeButtonClickTriger)
      .merge()
      .withLatestFrom(input.phoneTextFieldText)
      .map { phone -> String in
        "+" + phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
      }
      .flatMapLatest { phone -> Driver<String> in
        PhoneAuthProvider.provider().rx
          .verifyPhoneNumber(phone)
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }
     
    
    let isOTPCodeValid = input.OTPCodeTextFieldText
      .map { $0.isEmpty == false }
    
    let signUpWithPhone = Driver.of(input.OTPCodeTextFieldDidEndEditing, input.nextButtonClickTrigger)
      .merge()
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .otp }
      .withLatestFrom(isOTPCodeValid)
      .filter { $0 }
      .withLatestFrom(sendOtpCode)
      .withLatestFrom(input.OTPCodeTextFieldText) { verificationID, verificationCode -> PhoneAuthCredential in
        PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
      }
      .flatMapLatest { credential -> Driver<AuthDataResult> in
        Auth.auth().rx
          .signInAndRetrieveData(with: credential)
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }

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
      }
      .distinctUntilChanged()
 
    // auth
    let auth = Driver.of(
        signUpWithEmail,
        signInWithEmail,
        signUpWithPhone
      )
      .merge()
      .debug()
      .map { _ -> AppStep in
          .navigateBack
      }
      .do { step in
        self.steps.accept(step)
      }
    
    // RESET PASSWORD
    let resetPassword = input.resetPasswordButtonClickTrigger
      .withLatestFrom(input.emailTextFieldText)
      .flatMapLatest { email -> Driver<Void>  in
        Auth.auth().rx
          .sendPasswordReset(withEmail: email)
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }
    
    // Style handler
    let loginViewControllerStyleHandler = Driver.of(
      setEmailStyle,
      setPhoneStyle,
      setPasswordStyle,
      setRepeatPasswordStyle,
      setOtpStyle
    )
      .merge()
      .do { style in
        self.loginViewControllerStyle.accept(style)
      }
      .mapToVoid()
    
    // Navigate back
    let navigateBack = input.backButtonClickTrigger
      .withLatestFrom(loginViewControllerStyle)
      .filter { style -> Bool in
        return style == .phone || style == .email
      }
      .map { _ -> AppStep in
          .dismiss
      }
      .do { step in
        self.steps.accept(step)
      }
    
    // ERROR
    let clearError = loginViewControllerStyle
      .map { _ -> String in "" }
    
    let errorText = Driver.of(
      clearError,
      errorTracker.map { $0.localizedDescription }.debug()
    )
      .merge()
      .asDriver()
    
    return Output(
      // header
      navigateBack: navigateBack,
      // style
      loginViewControllerStyle: loginViewControllerStyle,
      loginViewControllerStyleHandler: loginViewControllerStyleHandler,
      // email
      sendEmailVerification: sendEmailVerification,
      // phone
      phoneNumberTextField: correctNumber,
      // repeat password
      setFocusOnRepeatPasswordTextField: setFocusOnRepeatPasswordTextField,
      // next button
      nextButtonIsEnabled: nextButtonIsEnabled,
      // auth
      auth: auth,
      // error
      errorText: errorText
    )
  }
}
// swiftlint:enable cyclomatic_complexity
