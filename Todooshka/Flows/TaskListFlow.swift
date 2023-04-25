//
//  TaskListFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 29.07.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class TaskListFlow: Flow {
  var root: Presentable {
    return rootViewController
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
    case .ideaTaskListIsRequired:
      return navigateToTaskList(taskListMode: .idea)
    case .overduedTaskListIsRequired:
      return navigateToTaskList(taskListMode: .overdued)

    case .kindListIsRequired:
      return navigateToKindOfTaskList()
      
    case .openKindIsRequired(let kind):
      return navigateToShowKindOfTask(kind: kind)
      
    case .navigateBack,
        .taskProcessingIsCompleted,
        .taskListIsCompleted:
      return navigateBack()

    case .dismiss:
      return dismiss()
      
    default:
      return .none
    }
  }
  
  private func navigateToTaskList(taskListMode: TaskListMode) -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, taskListMode: taskListMode)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToKindOfTaskList() -> FlowContributors {
    let viewController = KindListViewController()
    let viewModel = KindListViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTask(task: Task, taskListMode: TaskListMode) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, task: task, taskListMode: taskListMode)
    viewController.viewModel = viewModel
    if taskListMode == .main {
      rootViewController.tabBarController?.tabBar.isHidden = false
      rootViewController.present(viewController, animated: true)
    } else {
      rootViewController.tabBarController?.tabBar.isHidden = true
      rootViewController.pushViewController(viewController, animated: true)
    }
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToCreateKindOfTask() -> FlowContributors {
    let viewController = KindViewController()
    let viewModel = KindViewModel(services: services, kind: Kind(uuid: UUID()))
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToShowKindOfTask(kind: Kind) -> FlowContributors {
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
