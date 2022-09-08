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

enum LoginViewControllerStyle {
  case Email
  case OTPCode
  case Password
  case RepeatPassword
  case Phone
}

struct SignUpWithEmailAttr {
  let email: String
  let password: String
}

struct SignUpWithPhoneAttr {
  let verificationID: String
  let verificationCode: String
}

class LoginViewModel: Stepper {
  
  //MARK: - Properties
  let isNewUser: Bool
  let services: AppServices
  let steps = PublishRelay<Step>()
  var style: LoginViewControllerStyle = .Email

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
  }
  
  struct Output {
    let auth: Driver<Void>
    let correctPhoneFormat: Driver<String>
    let errorText: Driver<String>
    let navigateBack: Driver<Void>
    let nextButtonIsEnabled: Driver<Bool>
    let sendEmailVerification: Driver<Void>
    let setLoginViewControllerStyle: Driver<LoginViewControllerStyle>
    let updateUserData: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices, isNewUser: Bool) {
    self.services = services
    self.isNewUser = isNewUser
  }
  
  func transform(input: Input) -> Output {
    
    let next = Driver
      .of (input.nextButtonClickTrigger,
           input.emailTextFieldDidEndEditing,
           input.passwordTextFieldDidEndEditing.filter{ self.style == .Password },
           input.repeatPasswordTextFieldDidEndEditing.filter{ self.style == .RepeatPassword },
           input.phoneTextFieldDidEndEditing,
           input.OTPCodeTextFieldDidEndEditing
      ).merge()
    
    let setEmailStyleWithButtonClick = input.emailButtonClickTrigger
      .map { LoginViewControllerStyle.Email }
    
    let setPhoneStyleWithButtonClick = input.phoneButtonClickTrigger
      .map { LoginViewControllerStyle.Phone }

    let setEmailOrPhoneStyleWithNavigationBack = input.backButtonClickTrigger
      .compactMap { _ -> LoginViewControllerStyle? in
        switch self.style {
        case .Password, .RepeatPassword: return .Email
        case .OTPCode: return .Phone
        default: return nil
        }
      }
    
    let correctPhoneFormat = input.phoneTextFieldText
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
    
    let isPhoneValid = correctPhoneFormat
      .map { $0.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression).count }
      .map { $0 == 11 }
    
    let isEmailValid = input.emailTextFieldText
      .map { email -> Bool in
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
      }
    
    let setRepeatPasswordStyleWithNextButtonClick = next
      .withLatestFrom(isEmailValid)
      .filter{ $0 }
      .filter{ _ in self.style == .Email && self.isNewUser  }
      .map { _ in LoginViewControllerStyle.RepeatPassword }
    
    let setPasswordStyleWithNextButtonClick = next
      .withLatestFrom(isEmailValid)
      .filter{ $0 }
      .filter{ _ in self.style == .Email && self.isNewUser == false }
      .map { _ in LoginViewControllerStyle.Password }
    
    let setOTPCodeStyleWithNextButtonClick = next
      .withLatestFrom(isPhoneValid)
      .filter{ $0 }
      .filter { _ in self.style == .Phone }
      .map { _ in LoginViewControllerStyle.OTPCode }

    let loginViewControllerStyle = Driver.of(
      setEmailStyleWithButtonClick,
      setPhoneStyleWithButtonClick,
      setEmailOrPhoneStyleWithNavigationBack,
      setRepeatPasswordStyleWithNextButtonClick,
      setPasswordStyleWithNextButtonClick,
      setOTPCodeStyleWithNextButtonClick
    )
      .merge()
      .startWith(.Email)
      .distinctUntilChanged()
      .do { style in self.style = style }
    
    let clearError = loginViewControllerStyle
      .map { _ -> String in "" }
    
    let navigateBack = input.backButtonClickTrigger
      .withLatestFrom(loginViewControllerStyle) { _, style in
        switch style {
        case .Phone, .Email: self.steps.accept(AppStep.NavigateBack)
        default: return
        }
      }

    
    
    

    let isPasswordValid = input.passwordTextFieldText
      .map { $0.count >= 8 }
    
    let isRepeatPasswordValid = input.repeatPasswordTextFieldText
    .withLatestFrom(input.passwordTextFieldText) { $0 == $1 && $0 != "" }
    
    let isOTPCodeValid = input.OTPCodeTextFieldText
      .map { $0.isEmpty == false }
    
    let nextButtonIsEnabled = Driver
      .combineLatest(loginViewControllerStyle, isPhoneValid, isEmailValid, isPasswordValid, isRepeatPasswordValid, isOTPCodeValid) { style, isPhoneValid, isEmailValid, isPasswordValid, isRepeatPasswordValid, isOTPCodeValid -> Bool in
        switch style {
        case .Phone:
          return isPhoneValid
        case .Email:
          return isEmailValid
        case .Password:
          return isPasswordValid
        case .RepeatPassword:
          return isPasswordValid && isRepeatPasswordValid
        case .OTPCode:
          return isOTPCodeValid
        }
      }.distinctUntilChanged()
    
    let signUpWithEmailAttr = Driver<SignUpWithEmailAttr>
      .combineLatest(input.emailTextFieldText, input.passwordTextFieldText) { SignUpWithEmailAttr(email: $0, password: $1) }
    
    let createUserWithEmail = next
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .RepeatPassword }
      .withLatestFrom(signUpWithEmailAttr)
      .asObservable()
      .flatMapLatest { attr -> Observable<Result<AuthDataResult, Error>> in
        Auth.auth().rx.createUser(withEmail: attr.email, password: attr.password)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.StupidError))
    
    let errorTextCreateUserWithEmail = createUserWithEmail
      .map { result -> String in
        switch result {
        case .success(_): return ""
        case .failure(let error): return error.localizedDescription
        }
      }
    
    let sendEmailVerification = createUserWithEmail
      .compactMap { result -> AuthDataResult? in
        guard case .success(let authDataResult) = result else { return nil }
        return authDataResult
      }.asObservable()
      .flatMapLatest { result in
        result.user.rx.sendEmailVerification()
      }.asDriver(onErrorJustReturn: ())
      
    let errorTextUpdateUser = createUserWithEmail
      .map { result -> String in
        switch result {
        case .success(_): return ""
        case .failure(let error): return error.localizedDescription
        }
      }
    
    let signUpWithEmail = createUserWithEmail
      .map { result -> Void in
        switch result {
        case .success(_): self.steps.accept(AppStep.AuthIsCompleted)
        default: return
        }
      }
    
    let signInWithEmailCheckUser = next
      .withLatestFrom(loginViewControllerStyle)
      .filter { $0 == .Password}
      .withLatestFrom(signUpWithEmailAttr)
      .asObservable()
      .flatMapLatest { attr -> Observable<Result<AuthDataResult, Error>> in
        Auth.auth().rx.signIn(withEmail: attr.email, password: attr.password)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.StupidError))
      .debug()
    
    let errorTextSignInWithEmail = signInWithEmailCheckUser
      .map { result -> String in
        switch result {
        case .success(_): return ""
        case .failure(let error): return error.localizedDescription
        }
      }
    
    let signInWithEmail = signInWithEmailCheckUser
      .map { result -> Void in
        switch result {
        case .success(_): self.steps.accept(AppStep.AuthIsCompleted)
        default: return
        }
      }
    
    let sendOTPCode = next
      .withLatestFrom(loginViewControllerStyle)
      .filter{ $0 == .Phone }
      .withLatestFrom(input.phoneTextFieldText) {
        "+" + $1.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
      }.asObservable()
      .flatMapLatest { phone -> Observable<Result<String,Error>> in
        PhoneAuthProvider.provider().rx.verifyPhoneNumber(phone)
      }
    
    let verificationID = sendOTPCode
      .compactMap { result -> String? in
        guard case .success(let verificationID) = result else { return nil }
        return verificationID
      }.asDriver(onErrorJustReturn: "")
    
    let signUpWithPhoneAttr = Driver
      .combineLatest(verificationID, input.OTPCodeTextFieldText) { SignUpWithPhoneAttr(verificationID: $0, verificationCode: $1) }
    
    let errorTextSendingOTPCode = sendOTPCode
      .map { result -> String in
        switch result {
        case .success(_): return ""
        case .failure(let error): return error.localizedDescription
        }
      }.asDriver(onErrorJustReturn: "")
    
    let checkVerificationCode = next
      .withLatestFrom(loginViewControllerStyle)
      .filter{ $0 == .OTPCode }
      .withLatestFrom(isOTPCodeValid)
      .filter{ $0 }
      .withLatestFrom(signUpWithPhoneAttr) {
        PhoneAuthProvider.provider().credential(withVerificationID: $1.verificationID , verificationCode: $1.verificationCode)
      }.asObservable()
      .flatMapLatest { credential -> Observable<Result<AuthDataResult, Error>>  in
        Auth.auth().rx.signInAndRetrieveData(with: credential)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      
    let updateUserData = Driver
      .of (createUserWithEmail, checkVerificationCode)
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
    
    let errorTextCheckOTPCode = checkVerificationCode
      .map { result -> String in
        switch result {
        case .success(_): return ""
        case .failure(let error): return error.localizedDescription
        }
      }.asDriver(onErrorJustReturn: "")
      
    let signInWithPhone = checkVerificationCode
      .map { result -> Void in
        switch result {
        case .success(_): self.steps.accept(AppStep.AuthIsCompleted)
        default: return
        }
      }

    let errorText = Driver
      .of( clearError,
           errorTextCreateUserWithEmail,
           errorTextSignInWithEmail,
           errorTextUpdateUser,
           errorTextSendingOTPCode,
           errorTextCheckOTPCode
      ).merge()
    
    let auth = Driver
      .of (
        signUpWithEmail,
        signInWithEmail,
        signInWithPhone
      ).merge()

    return Output(
      auth: auth,
      correctPhoneFormat: correctPhoneFormat,
      errorText: errorText,
      navigateBack: navigateBack,
      nextButtonIsEnabled: nextButtonIsEnabled,
      sendEmailVerification: sendEmailVerification,
      setLoginViewControllerStyle: loginViewControllerStyle,
      updateUserData: updateUserData
    )
  }
}

