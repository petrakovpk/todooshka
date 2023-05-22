//
//  TaskFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 19.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class TaskFlow: Flow {
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
    case .openTaskIsRequired(let task, let taskListMode):
      return navigateToTask(task: task, taskListMode: taskListMode)
    case .kindListIsRequired:
      return navigateToKindList()
    case .openKindIsRequired(let kind):
      return navigateToOpenKind(kind: kind)
    case .resultPreviewIsRequired(let task):
      return navigateToResultPreview(task: task)
    case .navigateBack:
      return navigateBack()
    case .dismiss:
      return dismiss()
    default:
      return .none
    }
  }

  private func navigateToTask(task: Task, taskListMode: TaskListMode) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, task: task, taskListMode: taskListMode)
    viewController.viewModel = viewModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.setViewControllers([viewController], animated: true)
 //   rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToResultPreview(task: Task) -> FlowContributors {
    let viewController = ResultPreviewViewController()
    let viewModel = ResultPreviewViewModel(services: services, task: task)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToKindList() -> FlowContributors {
    let viewController = KindListViewController()
    let viewModel = KindListViewModel(services: services, kindListMode: .normal)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }


  private func navigateToOpenKind(kind: Kind) -> FlowContributors {
    let viewController = KindViewController()
    let viewModel = KindViewModel(services: services, kind: kind)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }

  private func dismiss() -> FlowContributors {
    rootViewController.dismiss(animated: true)
    return .none
  }
}
