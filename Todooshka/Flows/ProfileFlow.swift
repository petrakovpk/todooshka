//
//  ProfileFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.01.2023.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit

class ProfileFlow: Flow {
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
    case .profileIsRequired:
      return navigateToProfile()
    case .navigateBack:
      return navigateBack(tabBarIsHidden: true)
    default:
      return .none
    }
  }

  private func navigateToProfile() -> FlowContributors {
    let viewController = ProfileViewController()
    let viewModel = ProfileViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateBack(tabBarIsHidden: Bool) -> FlowContributors {
    rootViewController.tabBarController?.tabBar.isHidden = tabBarIsHidden
    rootViewController.popViewController(animated: true)
    return .none
  }
}

