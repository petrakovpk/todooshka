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
    case .marketplaceIsRequired:
      return navigateToMarketplace()
    case .navigateBack:
      return navigateBack(tabBarIsHidden: true)
    case .openThemeIsRequired(let themeUID, let openViewControllerMode):
      return navigateToTheme(themeUID: themeUID, openViewControllerMode: openViewControllerMode)
    case .openThemeIsCompleted:
      return navigateBack(tabBarIsHidden: false)
    case .themeDayIsRequired(let themeDayUID, let openViewControllerMode):
      return navigateToThemeDay(themeDayUID: themeDayUID, openViewControllerMode: openViewControllerMode)
    case .themeTaskIsRequired:
      return navigateToThemeTask()
    default:
      return .none
    }
  }

  private func navigateToMarketplace() -> FlowContributors {
    let viewController = MarketplaceViewController()
    let viewModel = MarketplaceViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTheme(themeUID: String, openViewControllerMode: OpenViewControllerMode) -> FlowContributors {
    let viewController = ThemeViewController()
    let viewModel = ThemeViewModel(services: services, themeUID: themeUID, openViewControllerMode: openViewControllerMode)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToThemeDay(themeDayUID: String, openViewControllerMode: OpenViewControllerMode) -> FlowContributors {
    let viewController = ThemeDayViewContoller()
    let viewModel = ThemeDayViewModel(services: services, themeDayUID: themeDayUID, openViewControllerMode: openViewControllerMode)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToThemeTask() -> FlowContributors {
    let viewController = ThemeTaskViewController()
    let viewModel = ThemeTaskViewModel(services: services)
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
