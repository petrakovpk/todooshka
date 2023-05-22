//
//  ChangePhoneViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import FirebaseAuth
import RxFlow
import RxSwift
import RxCocoa

class SetPhoneViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let reload = BehaviorRelay<Void>(value: ())

  struct Input {
    // header
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
    let isPhoneNotSet: Driver<Bool>
    let sendCodeButtonIsEnabled: Driver<Bool>
    let navigateBack: Driver<AppStep>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let errorTracker = ErrorTracker()
    let reload = reload.asDriver()

    let user = reload
      .asObservable()
      .flatMapLatest { _ -> Observable<User?>  in
        Auth.auth().rx.stateDidChange
      }
      .asDriver(onErrorJustReturn: nil)
      .compactMap { $0 }

    let isPhoneNotSet = Driver
      .combineLatest(reload, user) { $1.phoneNumber == nil }

    let phoneNumber = Driver
      .combineLatest(reload, user) { $1.phoneNumber ?? "" }

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
      .map { $0.count == 6 }

    // IS ENABLED
    let sendCodeButtonIsEnabled = Driver
      .combineLatest(isPhoneValid, isPhoneNotSet) { isPhoneValid, isPhoneNotSet -> Bool in
        isPhoneValid && isPhoneNotSet
      }

    // SEND
    let sendOTPCode = input.sendOTPCodeButtonClickTrigger
      .withLatestFrom(correctPhoneNumber) { "+" + $1.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression) }
      .asObservable()
      .flatMapLatest { phoneNumber -> Observable<String> in
        PhoneAuthProvider.provider().rx.verifyPhoneNumber(phoneNumber)
      }
      .trackError(errorTracker)
      .asDriver(onErrorJustReturn: "")

//    let signUpWithPhoneAttr = Driver
//      .combineLatest(
//        sendOTPCode,
//        correctOTPCode
//      ) { SignUpWithPhoneAttr(verificationID: $0, verificationCode: $1) }

    let credential = input.checkOTPCodeButtonClickTrigger
      .withLatestFrom(sendOTPCode)
      .withLatestFrom(correctOTPCode) { verificationID, verificationCode -> PhoneAuthCredential in
        PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
      }

    let link = credential
      .withLatestFrom(user) { ($0, $1) }
      .asObservable()
      .flatMapLatest { credential, user -> Observable<AuthDataResult> in
        user.rx.linkAndRetrieveData(with: credential)
      }
      .trackError(errorTracker)
 
    let navigateBack = input.backButtonClickTrigger
      .map { _ in AppStep.navigateBack }
      .do { step in
        self.steps.accept(step)
      }
    
    let errorText = errorTracker
      .map { $0.localizedDescription }
      .asDriver()

    return Output(
      checkOTPCodeButtonIsEnabled: isOTPCodeValid,
      correctOTPCode: correctOTPCode,
      correctPhoneNumber: correctPhoneNumber,
      errorText: errorText,
      isPhoneNotSet: isPhoneNotSet,
      sendCodeButtonIsEnabled: sendCodeButtonIsEnabled,
    //  successLink: successLink,
      navigateBack: navigateBack
    )
  }
}
