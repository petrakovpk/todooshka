//
//  ChangeNameViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class ChangeNameViewModel: Stepper {

  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let nameTextFieldEditingDidEndOnExit: Driver<Void>
    let nameTextFieldText: Driver<String>
    let saveButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let name: Driver<String>
    let navigateBack: Driver<Void>
    let save: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {

    let user = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
      .compactMap { $0 }

    let data = user
      .asObservable()
      .flatMapLatest { user in
        dbUserRef.child(user.uid).child("PERSONAL").rx.observeSingleEvent(.value)
      }.compactMap { snapshot -> NSDictionary? in
        snapshot.value as? NSDictionary ?? nil
      }

    let name = data
      .map { data -> String in data["name"] as? String ?? "" }
      .asDriver(onErrorJustReturn: "")
      .startWith("")

    let didEndEdiditing = Driver.of(input.nameTextFieldEditingDidEndOnExit, input.saveButtonClickTrigger).merge()

    let navigateBack = Driver
      .of(input.backButtonClickTrigger, didEndEdiditing)
      .merge()
      .map { _ in self.steps.accept(AppStep.navigateBack) }

    let save = Driver
      .combineLatest(didEndEdiditing, input.nameTextFieldText, user) { ($1, $2) }
      .asObservable()
      .flatMapLatest { (name, user) in
        dbUserRef.child(user.uid).child("PERSONAL").rx.updateChildValues(["name": name])
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
      .map { _ in ()}

    return Output(
      name: name,
      navigateBack: navigateBack,
      save: save
    )
  }
}
