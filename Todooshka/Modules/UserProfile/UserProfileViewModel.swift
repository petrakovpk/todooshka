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
      .map { $0.string(withFormat: "dd MMMM yyyy") }
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
      .map { data -> [UserProfileSectionModel] in
        [
          UserProfileSectionModel(header: "Личная информация", items: [
            UserProfileItem(type: .Name, leftText: "Имя", rightText: data.name),
            UserProfileItem(type: .Gender, leftText: "Пол", rightText: data.gender.rawValue ),
            UserProfileItem(type: .Birthday, leftText: "Дата рождения", rightText: data.birthday )]),
          
          UserProfileSectionModel(header: "Вход в приложение", items: [
            UserProfileItem(type: .Phone, leftText: "Телефон", rightText: data.phone),
            UserProfileItem(type: .Email, leftText: "Email", rightText: data.email),
            UserProfileItem(type: .Password, leftText: "Пароль", rightText: "Cменить пароль")]),
          
          UserProfileSectionModel(header: "История покупок", items: [])
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
        }
      }
    
    let title = user
      .map { $0.displayName ?? "Герой без имени" }
      .asDriver(onErrorJustReturn: "")
    
    let navigateBackIfUserLoggedOff = userListener
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

