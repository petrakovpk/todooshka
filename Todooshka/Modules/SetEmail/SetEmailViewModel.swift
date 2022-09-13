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
  }
  
  struct Output {
    let emailLabelText: Driver<String>
    let navigateBack: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let user = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
      .compactMap{ $0 }
    
    let email = user
      .map{ $0.email }
    
    let isEmailVerified = user
      .map{ $0.isEmailVerified }
    
    let emailLabelText = isEmailVerified
      .map{ $0 ? "У вас уже есть подвтержденный email" : "Введите Email и подтвердите его" }
     
    let navigateBack = input.backButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.NavigateBack) }
    
    return Output(
      emailLabelText: emailLabelText,
      navigateBack: navigateBack
    )
  }
}

