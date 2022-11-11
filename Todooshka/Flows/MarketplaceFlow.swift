//
//  MarketplaceFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class MarketplaceFlow: Flow {
  var root: Presentable {
    return self.rootViewController
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
    case .addThemeIsRequired:
      return navigateToAddTheme()
    case .marketplaceIsRequired:
      return navigateToMarketplace()
    case .navigateBack:
      return navigateBack(tabBarIsHidden: true)
    case .showThemeIsRequired(let themeUID):
      return navigateToTheme(themeUID: themeUID)
    case .showThemeIsCompleted:
      return navigateBack(tabBarIsHidden: false)
    case .themeDayIsRequired(let themeDayUID):
      return navigateToThemeDay(themeDayUID: themeDayUID)
    default:
      return .none
    }
  }
  
  private func navigateToAddTheme() -> FlowContributors {
    let viewController = AddThemeViewController()
    let viewModel = AddThemeViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToMarketplace() -> FlowContributors {
    let viewController = MarketplaceViewController()
    let viewModel = MarketplaceViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTheme(themeUID: String) -> FlowContributors {
    let viewController = ThemeViewController()
    let viewModel = ThemeViewModel(services: services, themeUID: themeUID)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToThemeDay(themeDayUID: String) -> FlowContributors {
    let viewController = ThemeDayViewContoller()
    let viewModel = ThemeDayViewModel(services: services, themeDayUID: themeDayUID)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateBack(tabBarIsHidden: Bool) -> FlowContributors {
    rootViewController.tabBarController?.tabBar.isHidden = tabBarIsHidden
    rootViewController.popViewController(animated: true)
    return .none
  }
}
