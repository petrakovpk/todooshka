//
//  ChangeBirthdayViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class ChangeBirthdayViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let datePicker: Driver<Date>
    let saveButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let dateText: Driver<String>
    let navigateBack: Driver<Void>
    let datePickerValue: Driver<Date>
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
        snapshot.value as? NSDictionary
      }

    let birthdayFromFirebase = data
      .compactMap { data -> Date? in
        guard let timeInterval = data["birthday"] as? Double else { return nil }
        return  Date(timeIntervalSince1970: timeInterval)
      }.asDriver(onErrorJustReturn: Date())

    let birdthdayFromWheel = input.datePicker

    let birthday = Driver
      .of(birdthdayFromWheel, birthdayFromFirebase)
      .merge()
      .asDriver()

    let dateText = birthday
      .map { self.services.preferencesService.formatter.string(from: $0) }

    let datePickerValue = birthday

    let save = Driver
      .combineLatest(input.saveButtonClickTrigger, birthday, user) { ($1, $2) }
      .asObservable()
      .flatMapLatest { birthday, user in
        dbUserRef.child(user.uid).child("PERSONAL").rx.updateChildValues(["birthday": birthday.timeIntervalSince1970])
      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
      .map { _ in () }

    let navigateBack = Driver
      .of(input.backButtonClickTrigger, input.saveButtonClickTrigger)
      .merge()
      .map { _ in self.steps.accept(AppStep.navigateBack) }

    return Output(
      dateText: dateText,
      navigateBack: navigateBack,
      datePickerValue: datePickerValue,
      save: save
    )
  }
}
