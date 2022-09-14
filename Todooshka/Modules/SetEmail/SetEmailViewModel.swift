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

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let emailTextFieldText: Driver<String>
    let sendVerificationEmailButtonClick: Driver<Void>
  }
  
  struct Output {
    let emailLabelText: Driver<String>
    let emailTextFieldText: Driver<String>
    let navigateBack: Driver<Void>
    let sendEmailVerification: Driver<Result<Void,Error>>
    let sendVerificationEmailButtonIsEnabled: Driver<Bool>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let user = Driver<User?>
      .of(Auth.auth().currentUser)
      .compactMap { $0 }
    
    let email = user
      .compactMap{ $0.email }
    
    let isEmailVerified = user
      .map{ $0.isEmailVerified }
      .debug()
    
    let emailLabelText = isEmailVerified
      .map{ $0 ? "Ваш основной email (подтвержден)" : "Ваш основной email (не подтвержден)" }

    let emailTextFieldText = email
    
    // IS VALID
    let isEmailValid = Driver.of(input.emailTextFieldText, email)
      .merge()
      .map { email -> Bool in
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
      }
    
    let sendEmailVerification = input.sendVerificationEmailButtonClick
      .withLatestFrom(isEmailValid) { $1 }
      .filter{ $0 }
      .withLatestFrom(input.emailTextFieldText) { $1 }
      .debug()
      .withLatestFrom(user){ ($0, $1) }.asObservable()
      .flatMapLatest { (email, user) -> Observable<Result<Void,Error>>  in
        user.rx.sendEmailVerification()
      }.debug()
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      
    
    let sendVerificationEmailButtonIsEnabled = Driver
      .combineLatest(isEmailVerified, isEmailValid) { isEmailVerified, isEmailValid -> Bool in
        isEmailValid && isEmailVerified == false
    }
    
    let navigateBack = input.backButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.NavigateBack) }
    
    return Output(
      emailLabelText: emailLabelText,
      emailTextFieldText: emailTextFieldText,
      navigateBack: navigateBack,
      sendEmailVerification: sendEmailVerification,
      sendVerificationEmailButtonIsEnabled: sendVerificationEmailButtonIsEnabled
    )
  }
}

