//
//  FeedFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 19.11.2022.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit

class FunFlow: Flow {
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
    case .funIsRequired:
      return navigateToFeed()
    case .navigateBack:
      return navigateBack(tabBarIsHidden: true)
    default:
      return .none
    }
  }

  private func navigateToFeed() -> FlowContributors {
    let viewController = FunViewController()
    let viewModel = FunViewModel(services: services)
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

