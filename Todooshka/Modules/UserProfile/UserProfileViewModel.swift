//
//  UserProfileViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 09.09.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class UserProfileViewModel: Stepper {
  
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let logOutButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let dataSource: Driver<[UserProfileSectionModel]>
    let itemSelected: Driver<Void>
    let logOut: Driver<Void>
    let navigateBack: Driver<Void>
    let title: Driver<String>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let currentUser = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
    
    let dataSource = Driver<[UserProfileSectionModel]>.of([
      UserProfileSectionModel(header: "Личная информация", items: [
        UserProfileItem(type: .Name, leftText: "Имя", rightText: "Павел Петраков"),
        UserProfileItem(type: .Gender, leftText: "Пол", rightText: "Мужской"),
        UserProfileItem(type: .Birthday, leftText: "Дата рождения", rightText: "21.11.1991")]),
      
      UserProfileSectionModel(header: "Вход в приложение", items: [
        UserProfileItem(type: .Phone, leftText: "Телефон", rightText: "+7 926 617 56 03"),
        UserProfileItem(type: .Email, leftText: "Email", rightText: "petrakovpk@gmail.com"),
        UserProfileItem(type: .Password, leftText: "Пароль", rightText: "сменить пароль")]),
      
      UserProfileSectionModel(header: "История покупок", items: [])
    ])
    
    let itemSelected = input.selection
      .withLatestFrom(dataSource) { $1[$0.section].items[$0.item] }
      .map { item in
        switch item.type {
        case .Name:
          self.steps.accept(AppStep.ChangingNameIsRequired)
        case .Gender:
          self.steps.accept(AppStep.ChangingGenderIsRequired)
        case .Birthday:
          self.steps.accept(AppStep.ChangingBirthdayIsRequired)
        case .Phone:
          self.steps.accept(AppStep.ChangingPhoneIsRequired)
        case .Email:
          self.steps.accept(AppStep.ChangingEmailIsRequired)
        case .Password:
          self.steps.accept(AppStep.ChangingPasswordIsRequired)
        }
      }
    
    let title = currentUser
      .map { $0?.displayName ?? "Герой без имени" }
      .asDriver(onErrorJustReturn: "Герой без имени")
    
    let navigateBackIfUserLoggedOff = currentUser
      .filter { $0 == nil }
      .map{ _ in () }
    
    let logOut = input.logOutButtonClickTrigger
      .do{ _ in
        do {
          try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
      }
    
    let navigateBack = Driver
      .of(navigateBackIfUserLoggedOff, input.backButtonClickTrigger)
      .merge()
      .map{ self.steps.accept(AppStep.NavigateBack) }

    return Output(
      dataSource: dataSource,
      itemSelected: itemSelected,
      logOut: logOut,
      navigateBack: navigateBack,
      title: title
    )
  }
}

