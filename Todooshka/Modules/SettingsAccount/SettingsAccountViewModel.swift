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

class SettingsAccountViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let showLogOffAlert = PublishRelay<Void>()
  
  private let services: AppServices

  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    // tableView
    let selection: Driver<IndexPath>
    // alert
    let alertCancelButtonClickTrigger: Driver<Void>
    let alertOkButtonClickTrigger: Driver<Void>
  }

  struct Output {
    // navigateBack
    let navigateBack: Driver<AppStep>
    // tableView
    let settingsSections: Driver<[SettingSection]>
  //  let selectItem: Driver<AppStep>
    let logOut: Driver<AppStep>
//    let dataSource: Driver<[UserProfileSection]>
//    let itemSelected: Driver<Void>
//    let hideLogOffAlert: Driver<Void>
//    let logOut: Driver<Void>
//
//    let showLogOffAlert: Driver<Void>
//    let title: Driver<String>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let errorTracker = ErrorTracker()
    let currentUser = services.currentUserService.user
    
    let logOutItem = Driver<SettingItem>.of(SettingItem(text: "Выйти из аккаунта", rightText: "", type: .logOutIsRequired))
  
    let settingsSections = logOutItem
      .map { item -> SettingSection in
        SettingSection(header: "Аккаунт", items: [item])
      }
      .map { section -> [SettingSection] in
        [section]
      }
    
    let selectItem = input.selection
      .withLatestFrom(settingsSections) { indexPath, sections -> SettingItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let logOut = selectItem
      .filter { $0.type == .logOutIsRequired }
      .flatMapLatest { item -> Driver<Void> in
        Auth.auth().rx.signOut()
          .trackError(errorTracker)
          .asDriverOnErrorJustComplete()
      }
      .map { _ -> AppStep in
          .navigateBack
      }
      .do { step in
        self.steps.accept(step)
      }
    
//    let reload = reloadData.asDriver()
//
//    let user = Driver
//      .combineLatest(reload, services.dataService.user ) { $1 }
//
//    let compactUser = services.dataService.compactUser
//
//    let snapshot = compactUser
//      .asObservable()
//      .flatMapLatest { user -> Observable<Result<DataSnapshot, Error>> in
//        Database.database().reference().child("USERS").child(user.uid).child("PERSONAL").rx.observeEvent(.value)
//      }.asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
//
//    let dict = snapshot
//      .compactMap({ result -> NSDictionary? in
//        guard case .success(let snapshot) = result,
//              let value = snapshot.value as? NSDictionary else { return nil }
//        return value
//      })
//
//    let birthday = dict
//      .compactMap { $0["birthday"] as? Double }
//      .map { Date(timeIntervalSince1970: $0) }
//      .map { $0.string() }
//     // .map { self.services.preferencesService.formatter.string(from: $0) }
//      .startWith("")
//
//    let gender = dict
//      .compactMap { $0["gender"] as? String }
//      .compactMap { Gender(rawValue: $0) }
//      .startWith(Gender.other)
//
//    let name = dict
//      .compactMap { $0["name"] as? String }
//      .startWith("Главный герой")
//
//    let email = compactUser
//      .compactMap { $0.email }
//      .startWith("")
//
//    let phoneNumber = compactUser
//      .compactMap { $0.phoneNumber }
//      .startWith("")
//
//    let userProfileData = Driver.combineLatest(name, birthday, gender, phoneNumber, email) { name, birthday, gender, phoneNumber, email -> UserProfileData in
//        UserProfileData(birthday: birthday, email: email, gender: gender, name: name, phone: phoneNumber)
//    }
//
//    let dataSource = userProfileData
//      .map { data -> [UserProfileSection] in
//        [
//          UserProfileSection(header: "Личная информация", items: [
//            UserProfileItem(type: .name, leftText: "Имя", rightText: data.name),
//            UserProfileItem(type: .gender, leftText: "Пол", rightText: data.gender.rawValue ),
//            UserProfileItem(type: .birthday, leftText: "Дата рождения", rightText: data.birthday )
//          ]),
//
//          UserProfileSection(header: "Аккаунт", items: [
//            UserProfileItem(type: .phone, leftText: "Телефон", rightText: data.phone),
//            UserProfileItem(type: .email, leftText: "Email", rightText: data.email),
//            UserProfileItem(type: .password, leftText: "Пароль", rightText: "Cменить пароль"),
//            UserProfileItem(type: .logOut, leftText: "Завершить сессию", rightText: "Выйти из аккаунта")
//          ]),
//
//          UserProfileSection(header: "Безопасность", items: [
//            UserProfileItem(type: .removeAccount, leftText: "Анонимность в сети", rightText: "Удалить аккаунт")
//          ]),
//
//          UserProfileSection(header: "История покупок", items: [])
//        ]
//      }.asDriver(onErrorJustReturn: [])
//
//    let itemSelected = input.selection
//      .withLatestFrom(dataSource) { indexPath, dataSource -> UserProfileItem in
//        dataSource[indexPath.section].items[indexPath.item]
//      }
//      .map { item in
//        switch item.type {
//        case .name:
//          self.steps.accept(AppStep.changingNameIsRequired)
//        case .gender:
//          self.steps.accept(AppStep.changingGenderIsRequired)
//        case .birthday:
//          self.steps.accept(AppStep.changingBirthdayIsRequired)
//        case .phone:
//          self.steps.accept(AppStep.changingPhoneIsRequired)
//        case .email:
//          self.steps.accept(AppStep.changingEmailIsRequired)
//        case .password:
//          self.steps.accept(AppStep.changingPasswordIsRequired)
//        case .logOut:
//          self.showLogOffAlert.accept(())
//        case .removeAccount:
//          self.steps.accept(AppStep.deleteAccountIsRequired)
//        }
//      }
//
//    let title = compactUser
//      .map { $0.displayName ?? "Герой без имени" }
//      .asDriver(onErrorJustReturn: "")
//
//    let logOut = input.alertOkButtonClickTrigger
//      .do { _ in
//        do {
//          try Auth.auth().signOut()
//        } catch let signOutError as NSError {
//          print("Error signing out: %@", signOutError)
//        }
//      }
//
//    let hideLogOffAlert = Driver
//      .of(input.alertOkButtonClickTrigger, input.alertCancelButtonClickTrigger)
//      .merge()
//
//    let showLogOffAlert = showLogOffAlert
//      .asDriver()
//      .compactMap { $0 }
//
    let navigateBack = input.backButtonClickTrigger
      .map { _ -> AppStep in
        AppStep.navigateBack
      }
      .do { step in
        self.steps.accept(step)
      }

    return Output(
      // navigate back
      navigateBack: navigateBack,
      // settingsSections
      settingsSections: settingsSections,
      logOut: logOut
//      dataSource: dataSource,
//      itemSelected: itemSelected,
//      hideLogOffAlert: hideLogOffAlert,
//      logOut: logOut,
//      navigateBack: navigateBack,
//      showLogOffAlert: showLogOffAlert,
//      title: title
    )
  }
}
