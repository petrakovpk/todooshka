//
//  DeleteAccountViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 03.10.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class DeleteAccountViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let deleteAccountClickTrigger: Driver<Void>
  }

  struct Output {
//    let deleteAccountButtonIsEnaled: Driver<Bool>
//    let errorText: Driver<String>
//    let navigateBack: Driver<Void>
//    let sucessText: Driver<String>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
//    let deleteAccountButtonIsEnaled = services.dataService.user
//      .map { $0 == nil ? false : true          }
//
//    let deleteAccount = input.deleteAccountClickTrigger
//      .withLatestFrom(services.dataService.compactUser) { $1 }
//      .asObservable()
//      .flatMapLatest { user in
//        user.rx.delete()
//      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
//
//    let deleteAccountError = deleteAccount
//      .compactMap { result -> Error? in
//        guard case .failure(let error) = result else { return nil }
//        return error
//      }
//
//    let deleteAccountSuccess = deleteAccount
//      .compactMap { result -> Void? in
//        guard case .success = result else { return nil }
//        return ()
//      }
//
//    let errorText = deleteAccountError
//      .map { $0.localizedDescription }
//
//    let sucessText = deleteAccountSuccess
//      .map { _ in "Аккаунт удален!" }
//
//    let navigateBackTrigger = services.dataService.user
//      .filter { $0 == nil }
//      .map { _ in () }
//
//    let navigateBack = Driver
//      .of(navigateBackTrigger, input.backButtonClickTrigger)
//      .merge()
//      .map { _ in self.steps.accept(AppStep.navigateBack) }

    return Output(
//      deleteAccountButtonIsEnaled: deleteAccountButtonIsEnaled,
//      errorText: errorText,
//      navigateBack: navigateBack,
//      sucessText: sucessText
    )
  }
}
