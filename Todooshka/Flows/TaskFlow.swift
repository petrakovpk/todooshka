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
  
  //MARK: - Properties
  var root: Presentable {
    return self.rootViewController
  }
  
  private let rootViewController = UINavigationController()
  private let services: AppServices
  
  //MARK: - Init
  init(withServices services: AppServices) {
    self.services = services
  }
  
  deinit {
    print("\(type(of: self)): \(#function)")
  }
  
  //MARK: - Flow Contributors
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    switch step {
    case .CreateTaskIsRequired:
      return navigateToTask(taskFlowAction: .create(status: .Created, closed: nil) )
    case .TaskTypesListIsRequired:
      return navigateToTaskTypesList()
    case .TaskTypesListIsCompleted:
      return navigateBack()
    case .TaskProcessingIsCompleted:
      return dismissTask()
    case .CreateTaskTypeIsRequired:
      return navigateToCreateTaskType()
    case .ShowTaskTypeIsRequired(let type):
      return navigateToShowTaskType(type: type)
    case .TaskTypeProcessingIsCompleted:
      return navigateBack()
    default:
      return .none
    }
  }
  
  private func navigateToTask(taskFlowAction: TaskFlowAction) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, taskFlowAction: taskFlowAction)
    viewController.viewModel = viewModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToTaskTypesList() -> FlowContributors {
    let viewController = TaskTypesListViewController()
    let viewModel = TaskTypesListViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToCreateTaskType() -> FlowContributors {
    let viewController = TaskTypeViewController()
    let viewModel = TaskTypeViewModel(services: services, action: .create)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToShowTaskType(type: TaskType) -> FlowContributors {
    let viewController = TaskTypeViewController()
    let viewModel = TaskTypeViewModel(services: services, action: .show(type: type))
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }
  
  private func dismissTask() -> FlowContributors {
    rootViewController.dismiss(animated: true)
    return .none
  }
}
