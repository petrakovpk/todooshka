//
//  ChangePhoneViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

enum PhoneSetMode {
  case Set
  case NotSet
}


class SetPhoneViewModel: Stepper {
  
  let services: AppServices
  let steps = PublishRelay<Step>()
 // var mode: SetPhoneViewModelMode = .Phone
  let reload = BehaviorRelay<Void>(value: ())
  
  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let checkOTPCodeButtonClickTrigger: Driver<Void>
    let phoneTextFieldText: Driver<String>
    let saveButtonClickTrigger: Driver<Void>
    let sendOTPCodeButtonClickTrigger: Driver<Void>
    let OTPCodeTextFieldText: Driver<String>
  }
  
  struct Output {
    let checkOTPCodeButtonIsEnabled: Driver<Bool>
    let correctOTPCode: Driver<String>
    let correctPhoneNumber: Driver<String>
    let errorText: Driver<String>
    let phoneSetMode: Driver<PhoneSetMode>
    let sendCodeButtonIsEnabled: Driver<Bool>
    let successLink: Driver<AuthDataResult>
    let navigateBack: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let reload = reload.asDriver()
    
    let user = reload
      .asObservable()
      .flatMapLatest { _ -> Observable<User?>  in
        Auth.auth().rx.stateDidChange
      }.asDriver(onErrorJustReturn: nil)
      .compactMap{ $0 }
    
    let phoneSetMode = Driver.combineLatest(reload, user) { _, user -> PhoneSetMode in
      user.phoneNumber == nil ? PhoneSetMode.NotSet: PhoneSetMode.Set
    }
    
    let phoneNumber = Driver
      .combineLatest(reload, user) { $1.phoneNumber ?? "" }
      .debug()

    // CORRECT
    let correctPhoneNumber = Driver
      .of(input.phoneTextFieldText, phoneNumber)
      .merge()
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
    
    let correctOTPCode = input.OTPCodeTextFieldText
      .map { phone -> String in
        let mask = "XXXXXX"
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
    let isPhoneValid = correctPhoneNumber
      .map { $0.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression).count }
      .map { $0 == 11 }
    
    let isOTPCodeValid = correctOTPCode
      .map{ $0.count == 6 }
    
    // IS ENABLED
    let sendCodeButtonIsEnabled = Driver
      .combineLatest(isPhoneValid, phoneSetMode) { isPhoneValid, phoneSetMode -> Bool in
        isPhoneValid && phoneSetMode == .NotSet
      }
    
    // SEND
    let sendOTPCode = input.sendOTPCodeButtonClickTrigger
      .withLatestFrom(correctPhoneNumber) { "+" + $1.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression) }
      .asObservable()
      .flatMapLatest { phoneNumber -> Observable<Result<String,Error>> in
        PhoneAuthProvider.provider().rx.verifyPhoneNumber(phoneNumber)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .debug()
    
    let verificationID = sendOTPCode
      .compactMap { result -> String? in
        guard case .success(let verificationID) = result else { return nil }
        return verificationID
      }.asDriver(onErrorJustReturn: "")
    
    let errorSendOTPCode = sendOTPCode
      .compactMap { result -> Error? in
        guard case .failure(let error) = result else { return nil }
        return error
      }.asDriver(onErrorJustReturn: ErrorType.DriverError)
        
    let signUpWithPhoneAttr = Driver
      .combineLatest(verificationID, correctOTPCode) { SignUpWithPhoneAttr(verificationID: $0, verificationCode: $1) }
      .debug()
    
    let credential = input.checkOTPCodeButtonClickTrigger
      .withLatestFrom(signUpWithPhoneAttr) {
        PhoneAuthProvider.provider().credential(withVerificationID: $1.verificationID , verificationCode: $1.verificationCode)
      }.debug()
    
    let link = credential
      .withLatestFrom(user) { ($0, $1) }
      .asObservable()
      .flatMapLatest { (credential, user) in
        user.rx.linkAndRetrieveData(with: credential)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let successLink = link
      .compactMap { result -> AuthDataResult? in
        guard case .success(let authDataResult) = result else { return nil }
        return authDataResult
      }.do { _ in self.reload.accept(()) }
    
    let errorLink = link
      .compactMap { result -> Error? in
        guard case .failure(let error) = result else { return nil }
        return error
      }
    
    let clearError = Driver
      .of(
        credential.map{ _ in ""},
        successLink.map{ _ in ""}
      ).merge()
      .asDriver()
    
    let errorText = Driver
      .of(
        errorSendOTPCode,
        errorLink
      ).merge()
      .map{ $0.localizedDescription }
    
    let errorFinal = Driver
      .of(
        errorText,
        clearError
      ).merge()
    
    let navigateBack = input.backButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.NavigateBack) }
    
    return Output(
      checkOTPCodeButtonIsEnabled: isOTPCodeValid,
      correctOTPCode: correctOTPCode,
      correctPhoneNumber: correctPhoneNumber,
      errorText: errorFinal,
      phoneSetMode: phoneSetMode,
      sendCodeButtonIsEnabled: sendCodeButtonIsEnabled,
      successLink: successLink,
      navigateBack: navigateBack
    )
  }
}


