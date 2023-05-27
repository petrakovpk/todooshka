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
      return navigateToFun()
    case .authIsRequired:
      return navigateToAuth()
    case .navigateBack:
      return navigateBack(tabBarIsHidden: true)
    default:
      return .none
    }
  }
  
  private func navigateToFun() -> FlowContributors {
    let viewController = FunViewController()
    let viewModel = FunViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToAuth() -> FlowContributors {
    let authFlow = AuthFlow(withServices: services)
    
    Flows.use(authFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .automatic
        rootViewController.present(root, animated: true)
      }
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: authFlow,
        withNextStepper: OneStepper(
          withSingleStep: AppStep.authIsRequired
        )
      )
    )
  }

  private func navigateBack(tabBarIsHidden: Bool) -> FlowContributors {
    rootViewController.tabBarController?.tabBar.isHidden = tabBarIsHidden
    rootViewController.popViewController(animated: true)
    return .none
  }
}

