//
//  FollowersViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import RxFlow
import RxSwift
import RxCocoa

class FollowersViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices

  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    // table view
  //  let settingIsSelected: Driver<IndexPath>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    // table
    let followersSections: Driver<[FollowersSection]>
//    // settings
//    let openTheSetting: Driver<AppStep>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let followersSections = Driver<[FollowersSection]>.just([
      FollowersSection(header: "", items: [
        FollowersItem(userUID: "123", image: UIImage(), nick: "Pasha", name: "Petya"),
        FollowersItem(userUID: "321", image: UIImage(), nick: "Posha", name: "Petya")
      ])
    ])
    
    let navigateBack = input.backButtonClickTrigger
      .map { _ in AppStep.navigateBack }
      .do { step in
        self.steps.accept(step)
      }

    return Output(
      // header
      navigateBack: navigateBack,
      // table
      followersSections: followersSections
    )
  }
}
