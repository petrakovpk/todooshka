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
  }
  
  struct Output {
    let auth: Driver<Void>
    let correctPhoneFormat: Driver<String>
    let errorText: Driver<String>
    let navigateBack: Driver<Void>
    let nextButtonIsEnabled: Driver<Bool>
    let sendEmailVerification: Driver<Void>
    let setLoginViewControllerStyle: Driver<LoginViewControllerStyle>
  }
  
  //MARK: - Init
  init(services: AppServices, isNewUser: Bool) {
    self.services = services
    self.isNewUser = isNewUser
  }
  
  func transform(input: Input) -> Output {
    
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
    
    let setRepeatPasswordStyleWithNextButtonClick = input.nextButtonClickTrigger
      .filter{ _ in self.style == .Email && self.isNewUser  }
      .map { LoginViewControllerStyle.RepeatPassword }
    
    let setPasswordStyleWithNextButtonClick = input.nextButtonClickTrigger
      .filter{ _ in self.style == .Email && self.isNewUser == false }
      .map { LoginViewControllerStyle.Password }
    
    let setOTPCodeStyleWithNextButtonClick = input.nextButtonClickTrigger
      .filter { _ in self.style == .Phone }
      .map { LoginViewControllerStyle.OTPCode }

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
    
    let createUserWithEmail = input.nextButtonClickTrigger
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
      
    let updateUserData = createUserWithEmail
      .compactMap { result -> AuthDataResult? in
        guard case .success(let authDataResult) = result else { return nil }
        return authDataResult
      }.asObservable()
      .flatMapLatest { authDataResult -> Observable<Result<DatabaseReference, Error>> in
        Database.database().reference().child("USERS").child(authDataResult.user.uid).rx.updateChildValues(["email": authDataResult.user.email, "displayName": authDataResult.user.displayName ])
      }.asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let errorTextUpdateUser = updateUserData
      .map { result -> String in
        switch result {
        case .success(_): return ""
        case .failure(let error): return error.localizedDescription
        }
      }
    
    let signUpWithEmail = updateUserData
      .map { result -> Void in
        switch result {
        case .success(_): self.steps.accept(AppStep.AuthIsCompleted)
        default: return
        }
      }
    
    let signInWithEmailCheckUser = input.nextButtonClickTrigger
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
    
    let sendOTPCode = input.nextButtonClickTrigger
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
    
    let checkVerificationCode = input.nextButtonClickTrigger
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
      setLoginViewControllerStyle: loginViewControllerStyle
    )
  }
  
  //MARK: - Bind Inputs
  //    func bindInputs() {
  //
  //        loginModeOutput.bind{[weak self] _ in
  //            guard let self = self else { return }
  //            self.errorTextFieldOutput.accept("")
  //            self.checkNextButton()
  //        }.disposed(by: disposeBag)
  //
  //        emailTextFieldInput.bind{[weak self] email in
  //            guard let self = self else { return }
  //            self.checkNextButton()
  //        }.disposed(by: disposeBag)
  //
  //        passwordTextFieldInput.bind{[weak self] _ in
  //            guard let self = self else { return }
  //            self.checkNextButton()
  //        }.disposed(by: disposeBag)
  //
  //        repeatPasswordTextFieldInput.bind{[weak self] _ in
  //            guard let self = self else { return }
  //            self.checkNextButton()
  //        }.disposed(by: disposeBag)
  //
  //        phoneTextFieldInput.bind{[weak self] phone in
  //            guard let self = self else { return }
  //            self.phoneTextFieldOutput.accept(self.phoneFormat(with: "+X (XXX) XXX XX XX", phone: phone))
  //            self.checkNextButton()
  //        }.disposed(by: disposeBag)
  //
  //        codeTextFieldInput.bind{[weak self] _ in
  //            guard let self = self else { return }
  //            self.checkNextButton()
  //        }.disposed(by: disposeBag)
  //
  //    }
  //
  //    //MARK: - Handlers
  //    func phoneButtonClick() {
  //        switch loginModeOutput.value {
  //        case .email, .password:
  //            loginModeOutput.accept(.phone)
  //        default:
  //            return
  //        }
  //    }
  //
  //    func emailButtonClick() {
  //        switch loginModeOutput.value {
  //        case .phone, .code:
  //            loginModeOutput.accept(.email)
  //        default:
  //            return
  //        }
  //    }
  //
  //    func nextButtonClick() {
  //
  //        if nextButtonIsEnabledOutput.value == false  { return }
  //
  //        switch loginModeOutput.value {
  //        case .email:
  //            loginModeOutput.accept(.password)
  //        case .phone:
  //            sendCode()
  //        case .password:
  //            isNewUser ? signUpWithEmail() : signInWithEmail()
  //        case .code:
  //            signUpWithPhone()
  //        }
  //    }
  //
  //    func backButtonClick() {
  //        switch loginModeOutput.value {
  //        case .password:
  //            loginModeOutput.accept(.email)
  //        case .code:
  //            loginModeOutput.accept(.phone)
  //        case .email, .phone:
  //            steps.accept(AppStep.createAccountIsCompleted)
  //        }
  //    }
  //
  //    func checkNextButton() {
  //        switch loginModeOutput.value {
  //        case .email:
  //            isValidEmail(emailTextFieldInput.value) ? nextButtonIsEnabledOutput.accept(true) : nextButtonIsEnabledOutput.accept(false)
  //        case .phone:
  //            phoneTextFieldInput.value == "" ? nextButtonIsEnabledOutput.accept(false) : nextButtonIsEnabledOutput.accept(true)
  //        case .password:
  //            if isNewUser {
  //                if passwordTextFieldInput.value != "",
  //                   passwordTextFieldInput.value == repeatPasswordTextFieldInput.value {
  //                    nextButtonIsEnabledOutput.accept(true)
  //                } else {
  //                    nextButtonIsEnabledOutput.accept(false)
  //                }
  //            } else {
  //                passwordTextFieldInput.value == "" ? nextButtonIsEnabledOutput.accept(false) : nextButtonIsEnabledOutput.accept(true)
  //            }
  //
  //        case .code:
  //            codeTextFieldInput.value == "" ? nextButtonIsEnabledOutput.accept(false) : nextButtonIsEnabledOutput.accept(true)
  //        }
  //    }
  //
  //    //MARK: - Auth Methods
  //    func signUpWithEmail() {
  //        services.networkAuthService.signUpWithEmail(withEmail: emailTextFieldInput.value, password: repeatPasswordTextFieldInput.value, fullname: "") { [weak self] error in
  //            guard let self = self else { return }
  //            if let error = error {
  //                print(error.localizedDescription)
  //                self.errorTextFieldOutput.accept(error.localizedDescription)
  //                return
  //            }
  //            self.steps.accept(AppStep.authIsCompleted)
  //        }
  //    }
  //
  //    func signInWithEmail() {
  //        services.networkAuthService.signInWithEmail(withEmail: emailTextFieldInput.value, password: passwordTextFieldInput.value) {[weak self] result, error in
  //            guard let self = self else { return }
  //            if let error = error {
  //                print(error.localizedDescription)
  //                self.errorTextFieldOutput.accept(error.localizedDescription)
  //                return
  //            }
  //            self.steps.accept(AppStep.authIsCompleted)
  //        }
  //    }
  //
  //    func sendCode() {
  //        var phone = phoneTextFieldOutput.value.replacingOccurrences(of: " ", with: "")
  //        phone = phone.replacingOccurrences(of: "(", with: "")
  //        phone = phone.replacingOccurrences(of: ")", with: "")
  //        services.networkAuthService.sendVerificationCodeWithPhone(withPhone: phone) {[weak self] verificationId, error in
  //            guard let self = self else { return }
  //            guard let verificationId = verificationId else { return }
  //
  //            if let error = error {
  //                print(error.localizedDescription)
  //                self.errorTextFieldOutput.accept(error.localizedDescription)
  //                return
  //            }
  //
  //            self.verificationId = verificationId
  //            self.loginModeOutput.accept(.code)
  //        }
  //    }
  //
  //    func signUpWithPhone() {
  //        services.networkAuthService.signInWithPhone(verificationID: verificationId, verificationCode: codeTextFieldInput.value) {[weak self]  error in
  //            guard let self = self else { return }
  //            if let error = error {
  //                print(error.localizedDescription)
  //                self.errorTextFieldOutput.accept(error.localizedDescription)
  //                return
  //            }
  //            self.steps.accept(AppStep.authIsCompleted)
  //        }
  //    }
  //
 
}

