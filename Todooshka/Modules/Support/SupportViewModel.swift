//
//  SupportViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 03.10.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

struct QuestionAttr {
  let email: String
  let question: String
}

class SupportViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let emailTextFieldText: Driver<String>
    let questionTextViewText: Driver<String>
    let sendButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let navigateBack: Driver<Void>
    let sendButtonIsEnabled: Driver<Bool>
    let sendQuestion: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let isEmailValid = input.emailTextFieldText
      .map { email -> Bool in
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
      }

    let isQuestionValid = input.questionTextViewText
      .map { $0.isEmpty == false }

    let sendButtonIsEnabled = Driver
      .combineLatest(isEmailValid, isQuestionValid) { isEmailValid, isQuestionValid -> Bool in
        isEmailValid && isQuestionValid
      }

    let questionAttr = Driver
      .combineLatest(input.emailTextFieldText, input.questionTextViewText) { email, question -> QuestionAttr in
        QuestionAttr(email: email, question: question)
      }

    let sendQuestion = input.sendButtonClickTrigger
      .withLatestFrom(questionAttr) { $1 }
      .asObservable()
      .flatMapLatest { question in
        dbRef.child("SUPPORT").child(UUID().uuidString).rx.updateChildValues(["email": question.email, "question": question.question])
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let sendQuestionSuccess = sendQuestion
      .compactMap { result -> Void? in
        guard case .success(let result) = result else { return nil }
        return ()
      }

    let navigateBack = input.backButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.navigateBack) }

    return Output(
      navigateBack: navigateBack,
      sendButtonIsEnabled: sendButtonIsEnabled,
      sendQuestion: sendQuestionSuccess
    )
  }
}
