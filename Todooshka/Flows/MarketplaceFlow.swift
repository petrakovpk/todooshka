//
//  MarketplaceFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import RxCocoa
import RxFlow
import RxSwift
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
    case .dismissAndNavigateBack:
      return dismissAndNavigateBack(tabBarIsHidden: true)
    case .navigateBack:
      return navigateBack(tabBarIsHidden: true)
    case .themeIsRequired(let theme):
      return navigateToTheme(theme: theme)
    case .themeSettingsIsRequired(let theme):
      return navigateToThemeSettings(theme: theme)
    case .themeProcessingIsCompleted:
      return navigateBack(tabBarIsHidden: false)
    case .themeStepIsRequired(let themeStep, let openViewControllerMode):
      return navigateToThemeStep(themeStep: themeStep, openViewControllerMode: openViewControllerMode)
    case .themeTaskIsRequired(let themeTaskUID, let openViewControllerMode):
      return navigateToThemeTask(themeTaskUID: themeTaskUID, openViewControllerMode: openViewControllerMode)
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

  private func navigateToTheme(theme: Theme) -> FlowContributors {
    let viewController = ThemeViewController()
    let viewModel = ThemeViewModel(services: services, theme: theme)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToThemeSettings(theme: Theme) -> FlowContributors {
    let viewController = ThemeSettingsViewController()
    let viewModel = ThemeSettingsViewModel(services: services, theme: theme)
    viewController.viewModel = viewModel
    if let sheet = viewController.sheetPresentationController {
      sheet.detents = [.medium()]
    }
    rootViewController.present(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToThemeStep(themeStep: ThemeStep, openViewControllerMode: OpenViewControllerMode) -> FlowContributors {
    let viewController = ChallengeViewController()
    let viewModel = ChallengeViewModel(services: services, themeStep: themeStep, openViewControllerMode: openViewControllerMode)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToThemeTask(themeTaskUID: String, openViewControllerMode: OpenViewControllerMode) -> FlowContributors {
    let viewController = ThemeTaskViewController()
    let viewModel = ThemeTaskViewModel(services: services, themeTaskUID: themeTaskUID, openViewControllerMode: openViewControllerMode)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func dismissAndNavigateBack(tabBarIsHidden: Bool) -> FlowContributors {
    rootViewController.tabBarController?.tabBar.isHidden = tabBarIsHidden
    rootViewController.dismiss(animated: true)
    return .one(flowContributor: .forwardToCurrentFlow(withStep: AppStep.navigateBack))
  }
  
  private func navigateBack(tabBarIsHidden: Bool) -> FlowContributors {
    rootViewController.tabBarController?.tabBar.isHidden = tabBarIsHidden
    rootViewController.popViewController(animated: true)
    return .none
  }
}
