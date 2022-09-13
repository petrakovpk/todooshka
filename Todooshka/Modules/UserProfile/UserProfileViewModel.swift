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
    
    let user = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
    
    let data = user
      .compactMap{ $0 }
      .asObservable()
      .flatMapLatest { user -> Observable<DataSnapshot> in
        Database.database().reference().child("USERS").child(user.uid).child("PERSONAL").rx.observeEvent(.value)
      }.compactMap { snapshot -> NSDictionary? in
        guard let value = snapshot.value as? NSDictionary else { return nil }
        return value
      }.map { data -> UserProfileData in
        var birthday = "Не указано"
        
        if let timeInterval = data["birthday"] as? Double {
          birthday = Date(timeIntervalSince1970: timeInterval).string(withFormat: "dd MMMM yyyy")
        }
        
        return UserProfileData(
          birthday: birthday,
          email: "",
          gender: Gender(rawValue: data["gender"] as? String ?? Gender.Other.rawValue) ?? Gender.Other,
          name: data["name"] as? String ?? "Главный герой",
          phone: ""
        )}.withLatestFrom(user) { userProfileData, user -> UserProfileData in
          UserProfileData(
            birthday: userProfileData.birthday,
            email: user?.email ?? "",
            gender: userProfileData.gender ,
            name: userProfileData.name,
            phone: user?.phoneNumber ?? "")
        }.startWith(UserProfileData(birthday: "", email: "", gender: Gender.Other, name: "", phone: ""))
    
    let dataSource = data
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
      .map { $0?.displayName ?? "Герой без имени" }
      .asDriver(onErrorJustReturn: "Герой без имени")
    
    let navigateBackIfUserLoggedOff = user
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

