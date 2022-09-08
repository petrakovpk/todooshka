//
//  AuthFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class AuthFlow: Flow {
  
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
    case .AuthIsRequired:
      return navigateToAuthScreen()
    case .AuthIsCompleted:
      return dismissAuthScreen()
    case .CreateAccountIsRequired:
      return navigateToCreateAccountScreen(isNewUser: true)
    case .LogInIsRequired:
      return navigateToCreateAccountScreen(isNewUser: false)
    case .NavigateBack:
      return navigateBack()
    default:
      return .none
    }
  }
  
  private func navigateToAuthScreen() -> FlowContributors {
    let viewController = AuthViewController()
    let viewModel = AuthViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToCreateAccountScreen(isNewUser: Bool) -> FlowContributors {
    let viewController = LoginViewController()
    let viewModel = LoginViewModel(services: services, isNewUser: isNewUser)
    viewController.viewModel = viewModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }
  
  private func dismissAuthScreen() -> FlowContributors {
    rootViewController.dismiss(animated: true)
    return .end(forwardToParentFlowWithStep: AppStep.AuthIsCompleted)
  }
}
