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
  // MARK: - Properties
  var root: Presentable {
    return self.rootViewController
  }

  private let rootViewController = UINavigationController()
  private let services: AppServices

  // MARK: - Init
  init(withServices services: AppServices) {
    self.services = services
  }

  deinit {
    print("\(type(of: self)): \(#function)")
  }

  // MARK: - Flow Contributors
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    switch step {
    case .openTaskIsRequired(let task, let isModal):
      return navigateToTask(task: task, isModal: isModal)
    case .kindsOfTaskListIsRequired:
      return navigateToTaskTypesList()
    case .createKindOfTaskIsRequired:
      return navigateToCreateKindOfTask()
    case .showKindOfTaskIsRequired(let kindOfTask):
      return navigateToShowTaskType(kindOfTask: kindOfTask)
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

  private func navigateToTask(task: Task, isModal: Bool) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, task: task, isModal: isModal)
    viewController.viewModel = viewModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToResultPreview(task: Task) -> FlowContributors {
    let viewController = ResultPreviewViewController()
    let viewModel = ResultPreviewViewModel(services: services, task: task)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTaskTypesList() -> FlowContributors {
    let viewController = KindOfTaskListViewController()
    let viewModel = KindOfTaskListViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToCreateKindOfTask() -> FlowContributors {
    let viewController = KindOfTaskViewController()
    let viewModel = KindOfTaskViewModel(services: services, kindOfTaskUID: UUID().uuidString)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToShowTaskType(kindOfTask: KindOfTask) -> FlowContributors {
    let viewController = KindOfTaskViewController()
    let viewModel = KindOfTaskViewModel(services: services, kindOfTaskUID: kindOfTask.UID)
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
