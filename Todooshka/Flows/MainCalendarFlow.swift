//
//  CalendarFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class MainCalendarFlow: Flow {
  var root: Presentable {
    self.rootViewController
  }

  private let rootViewController = UINavigationController()
  private let services: AppServices

  init(withServices services: AppServices) {
    self.services = services
  }

  deinit {
    print("\(type(of: self)): \(#function)")
  }

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    switch step {
    case .mainCalendarIsRequired:
      return navigateToMainCalendar()
    
    case .shopIsRequired:
      return navigateToShop()
    case .showBirdIsRequired(let bird):
      return navigateToBird(bird: bird)
      
    case .navigateBack:
      return navigateBack()
    default:
      return .none
    }
  }

  private func navigateToMainCalendar() -> FlowContributors {
    let viewController = MainCalendarViewController()
    let viewModel = MainCalendarViewModel(services: services)
    let sceneModel = MainCalendarSceneModel(services: services)
    viewController.viewModel = viewModel
    viewController.sceneModel = sceneModel
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToShop() -> FlowContributors {
    let viewController = ShopViewController()
    let viewModel = ShopViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
    private func navigateToBird(bird: Bird) -> FlowContributors {
      let viewController = BirdViewController()
      let viewModel = BirdViewModel(birdUID: bird.UID, services: services)
      viewController.viewModel = viewModel
      rootViewController.pushViewController(viewController, animated: true)
      return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
  
  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
    }
}
