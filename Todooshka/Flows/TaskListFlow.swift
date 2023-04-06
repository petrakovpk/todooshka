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
    rootViewController
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
      return navigateToTaskList(mode: .idea)
    case .overduedTaskListIsRequired:
      return navigateToTaskList(mode: .overdued)
      
//    case .createTaskIsRequired(let task, let isModal):
//      return navigateToTask(task: task, isModal: isModal)
//    case .openTaskIsRequired(let task):
//      return navigateToTask(task: task, isModal: false )
      
    case .kindsOfTaskListIsRequired:
      return navigateToKindOfTaskList()
      
    case .createKindOfTaskIsRequired:
      return navigateToCreateKindOfTask()
    case .showKindOfTaskIsRequired(let kindOfTask):
      return navigateToShowKindOfTask(kindOfTask: kindOfTask)
      
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
  
  private func navigateToTaskList(mode: TaskListMode) -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: mode)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToKindOfTaskList() -> FlowContributors {
    let viewController = KindOfTaskListViewController()
    let viewModel = KindOfTaskListViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTask(task: Task, isModal: Bool) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, task: task, isModal: isModal)
    viewController.viewModel = viewModel
    if isModal {
      rootViewController.tabBarController?.tabBar.isHidden = false
      rootViewController.present(viewController, animated: true)
    } else {
      rootViewController.tabBarController?.tabBar.isHidden = true
      rootViewController.pushViewController(viewController, animated: true)
    }
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToCreateKindOfTask() -> FlowContributors {
    let viewController = KindOfTaskViewController()
    let viewModel = KindOfTaskViewModel(services: services, kindOfTaskUID: UUID().uuidString )
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToShowKindOfTask(kindOfTask: KindOfTask) -> FlowContributors {
    let viewController = KindOfTaskViewController()
    let viewModel = KindOfTaskViewModel(services: services, kindOfTaskUID: kindOfTask.UID )
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
