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
  
  let reloadData = BehaviorRelay<Void>(value: ())
  let services: AppServices
  let steps = PublishRelay<Step>()
  let showLogOffAlert = BehaviorRelay<Void?>(value: nil)

  struct Input {
    let alertCancelButtonClickTrigger: Driver<Void>
    let alertOkButtonClickTrigger: Driver<Void>
    let backButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let dataSource: Driver<[UserProfileSection]>
    let itemSelected: Driver<Void>
    let hideLogOffAlert: Driver<Void>
    let logOut: Driver<Void>
    let navigateBack: Driver<Void>
    let showLogOffAlert: Driver<Void>
    let title: Driver<String>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let reload = reloadData.asDriver()
    let userListener = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
    
    let user = Driver
      .combineLatest(reload, userListener.compactMap{ $0 }) { $1 }

    let snapshot = user
      .asObservable()
      .flatMapLatest { user -> Observable<Result<DataSnapshot,Error>> in
        Database.database().reference().child("USERS").child(user.uid).child("PERSONAL").rx.observeEvent(.value)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let dict = snapshot
      .compactMap({ result -> NSDictionary? in
        guard case .success(let snapshot) = result,
              let value = snapshot.value as? NSDictionary else { return nil }
        return value
      })
    
    let birthday = dict
      .compactMap { $0["birthday"] as? Double }
      .map { Date(timeIntervalSince1970: $0) }
      .map { self.services.preferencesService.formatter.string(from: $0) }
      .startWith("")
    
    let gender = dict
      .compactMap{ $0["gender"] as? String }
      .compactMap{ Gender(rawValue: $0) }
      .startWith(Gender.Other)
    
    let name = dict
      .compactMap{ $0["name"] as? String }
      .startWith("Главный герой")
    
    let email = user
      .compactMap{ $0.email }
      .startWith("")
    
    let phoneNumber = user
      .compactMap{ $0.phoneNumber }
      .startWith("")
    
    let userProfileData = Driver.combineLatest(name, birthday, gender, phoneNumber, email) { name, birthday, gender, phoneNumber, email -> UserProfileData in
        UserProfileData(birthday: birthday, email: email, gender: gender, name: name, phone: phoneNumber)
      }
    
    let dataSource = userProfileData
      .map { data -> [UserProfileSection] in
        [
          UserProfileSection(header: "Личная информация", items: [
            UserProfileItem(type: .Name, leftText: "Имя", rightText: data.name),
            UserProfileItem(type: .Gender, leftText: "Пол", rightText: data.gender.rawValue ),
            UserProfileItem(type: .Birthday, leftText: "Дата рождения", rightText: data.birthday )
          ]),
          
          UserProfileSection(header: "Аккаунт", items: [
            UserProfileItem(type: .Phone, leftText: "Телефон", rightText: data.phone),
            UserProfileItem(type: .Email, leftText: "Email", rightText: data.email),
            UserProfileItem(type: .Password, leftText: "Пароль", rightText: "Cменить пароль"),
            UserProfileItem(type: .LogOut, leftText: "Завершить сессию", rightText: "Выйти из аккаунта")
          ]),
          
          UserProfileSection(header: "Безопасность", items: [
            UserProfileItem(type:.RemoveAccount, leftText: "Анонимность в сети", rightText: "Удалить аккаунт")
          ]),
          
          UserProfileSection(header: "История покупок", items: [])
        ]
      }.asDriver(onErrorJustReturn: [])

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
        case .LogOut:
          self.showLogOffAlert.accept(())
        case .RemoveAccount:
          self.steps.accept(AppStep.DeleteAccountIsRequired)
        }
      }
    
    let title = user
      .map { $0.displayName ?? "Герой без имени" }
      .asDriver(onErrorJustReturn: "")
    
    let navigateBackIfUserLoggedOff = userListener
      .filter { $0 == nil }
      .map{ _ in () }
    
    let logOut = input.alertOkButtonClickTrigger
      .do { _ in
        do {
          try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
      }
    
    let hideLogOffAlert = Driver
      .of(input.alertOkButtonClickTrigger, input.alertCancelButtonClickTrigger)
      .merge()
    
    let showLogOffAlert = showLogOffAlert
      .asDriver()
      .compactMap{ $0 }
    
    let navigateBack = Driver
      .of(navigateBackIfUserLoggedOff, input.backButtonClickTrigger)
      .merge()
      .map{ self.steps.accept(AppStep.NavigateBack) }

    return Output(
      dataSource: dataSource,
      itemSelected: itemSelected,
      hideLogOffAlert: hideLogOffAlert,
      logOut: logOut,
      navigateBack: navigateBack,
      showLogOffAlert: showLogOffAlert,
      title: title
    )
  }
}

