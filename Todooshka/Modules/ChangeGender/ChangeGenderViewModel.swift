//
//  ChangeGenderViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class ChangeGenderViewModel: Stepper {
  
  let services: AppServices
  let steps = PublishRelay<Step>()
  let selectedGender = BehaviorRelay<Gender>(value: .Other)

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let saveButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let dataSource: Driver<[ChangeGenderSectionModel]>
    let itemSelected: Driver<Void>
    let navigateBack: Driver<Void>
    let save: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let user = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
      .compactMap{ $0 }
    
    let data = user
      .asObservable()
      .flatMapLatest { user in
        DB_USERS_REF.child(user.uid).child("PERSONAL").rx.observeSingleEvent(.value)
      }.compactMap { snapshot -> NSDictionary? in
        snapshot.value as? NSDictionary ?? nil
      }
    
    let selectedGender = selectedGender.asDriver()
    
    let genderFromFirebase = data
      .map { data -> Gender in
        guard let rawValue = data["gender"] as? String,
              let gender = Gender(rawValue: rawValue) else { return Gender.Other }
         return gender
      }.asDriver(onErrorJustReturn: Gender.Other)
    
    let gender = Driver
      .of(selectedGender, genderFromFirebase)
      .merge()
  
    let dataSource = gender
      .map { gender -> [ChangeGenderSectionModel] in
        [ChangeGenderSectionModel(header: "Выберите пол", items: [
          ChangeGenderItem(gender: .Male, isSelected: gender == .Male),
          ChangeGenderItem(gender: .Female, isSelected: gender == .Female),
          ChangeGenderItem(gender: .Other, isSelected: gender == .Other)
        ])]
      }
    
    let itemSelected = input.selection
      .withLatestFrom(dataSource) { $1[$0.section].items[$0.item].gender }
      .asDriver()
      .map { gender -> Void in
        self.selectedGender.accept(gender)
        return ()
      }
    
    let save = Driver
      .combineLatest(input.saveButtonClickTrigger, gender, user) { ($1, $2) }
      .asObservable()
      .flatMapLatest { (gender, user) in
        DB_USERS_REF.child(user.uid).child("PERSONAL").rx.updateChildValues(["gender": gender.rawValue])
      }.asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .map{ _ in () }
    
    let navigateBack = Driver
      .of(input.backButtonClickTrigger, input.saveButtonClickTrigger)
      .merge()
      .map { _ in self.steps.accept(AppStep.NavigateBack) }
    
    return Output(
      dataSource: dataSource,
      itemSelected: itemSelected,
      navigateBack: navigateBack,
      save: save
    )
  }
  
}

