//
//  ProfileViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.01.2023.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class UserProfileViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  
  struct Input {
    // header
    let settingsButtonClickTrigger: Driver<Void>
    // auth
    let authButtonClickTrigger: Driver<Void>
    // avavar
    let avatarImageViewClickTrigger: Driver<Void>
    // subscribe
    let subscribeButtonClickTrigger: Driver<Void>
    // subscriptions and followers
    let subscriptionsLabelClickTrigger: Driver<Void>
    let followersLabelClickTrigger: Driver<Void>
    // pageViewController
    let publicationListButtonClickTrigger: Driver<Void>
    let taskListButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // header
    let titleText: Driver<String>
    let openSettings: Driver<AppStep>
    // pleaseAuthContainerViewIsHidden
    let pleaseAuthContainerViewIsHidden: Driver<Bool>
    // avatar
    let extUserDataImage: Driver<UIImage?>
    let openAvatar: Driver<AppStep>
    // open followers and subscriptions
    let openFollowers: Driver<AppStep>
    let openSubscriptions: Driver<AppStep>
    // subscribe
    let subscribe: Driver<Void>
    // auth
    let auth: Driver<AppStep>
    // pageViewController
    let scrollToPage: Driver<Int>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let currentUser = services.currentUserService.user
    let extUserData = services.currentUserService.extUserData

    let pleaseAuthContainerViewIsHidden = currentUser
      .map { $0 != nil }
    
    let titleText = currentUser
      .debug()
      .map { user -> String in
        user?.displayName ?? "Профиль"
      }
      .debug()
      
    let auth = input.authButtonClickTrigger
      .map { _ -> AppStep in
          .authIsRequired
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let extUserDataImage = extUserData
      .map { $0?.image }
    
    let openAvatar = input.avatarImageViewClickTrigger
      .map { _ -> AppStep in
          .imagePickerIsRequired
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let openFollowers = input.followersLabelClickTrigger
      .map { _ -> AppStep in
          .followersIsRequired
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let openSubscriptions = input.subscriptionsLabelClickTrigger
      .map { _ -> AppStep in
          .subsriptionsIsRequired
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let subscribe = input.subscribeButtonClickTrigger
    
    let openSettings = input.settingsButtonClickTrigger
      .map { _ -> AppStep in
        AppStep.settingsIsRequired
      }
      .do { step in
        self.steps.accept(step)
        
      }
    
    let scrollToFirstPage = input.publicationListButtonClickTrigger.map { 0 }
    let scrollToSecondPage = input.taskListButtonClickTrigger.map { 1 }
    
    let scrollToPage = Driver
      .of(scrollToFirstPage, scrollToSecondPage)
      .merge()
    
    return Output(
      // header
      titleText: titleText,
      openSettings: openSettings,
      // pleaseAuthContainerViewIsHidden
      pleaseAuthContainerViewIsHidden: pleaseAuthContainerViewIsHidden,
      // avatar
      extUserDataImage: extUserDataImage,
      openAvatar: openAvatar,
      // followers and subscriptions
      openFollowers: openFollowers,
      openSubscriptions: openSubscriptions,
      // subscribe
      subscribe: subscribe,
      // auth
      auth: auth,
      // pageViewController
      scrollToPage: scrollToPage
    )
  }
}
