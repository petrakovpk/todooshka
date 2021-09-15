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
    case .taskListIsRequired:
      return navigateToTaskList()
      
    case .overdueTaskListIsRequired:
      return navigateToOverdueTaskFlow()
    case .overdueTaskListIsCompleted:
      return navigateBack()
      
    case .ideaBoxTaskListIsRequired:
      return navigateToIdeaBoxTaskList()
    case .ideaBoxTaskListIsCompleted:
      return navigateBack()
      
    case .taskTypeIsRequired(let taskType):
      return navigateToTaskType(taskType: taskType)
    case .taskTypeIsCompleted:
      return navigateBack()
      
    case .createTaskIsRequired(let status, let date):
      return navigateToTask(taskFlowAction: .createTask(status: status, closedDate: date))
    case .showTaskIsRequired(let task):
      return navigateToTask(taskFlowAction: .showTask(task: task))
    case .taskProcessingIsCompleted:
      return navigateBack()
      
    case .taskTypesListIsRequired:
      return navigateToTaskTypesList()
    case .taskTypesListIsCompleted:
      return navigateBack()
      
    case .removeTaskConfirmationIsRequired:
      return navigateToRemoveConfirmation()
      
    default:
      return .none
    }
  }
  
  private func navigateToTaskList() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services)
    viewController.bindTo(with: viewModel)
    rootViewController.navigationBar.isHidden = true
    rootViewController.tabBarController?.tabBar.isHidden = false
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToRemoveConfirmation() -> FlowContributors {
    let alertFlow = AlertFlow(withServices: services)
    
    Flows.use(alertFlow, when: .created) { [unowned self] root in
        DispatchQueue.main.async {
          root.modalPresentationStyle = .fullScreen
            rootViewController.present(root, animated: true)
        }
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: alertFlow,
                                             withNextStepper: OneStepper(withSingleStep: AppStep.removeTaskConfirmationIsRequired)))
  }
  
  private func navigateToOverdueTaskFlow() -> FlowContributors {
    let viewController = OverdueTasksListViewController()
    let viewModel = OverdueTaskListViewModel(services: services)
    viewController.bindTo(with: viewModel)
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToTaskTypesList() -> FlowContributors {
    let viewController = TaskTypesListViewController()
    let viewModel = TaskTypesListViewModel(services: services)
    viewController.bindTo(with: viewModel)
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToTask(taskFlowAction: TaskFlowAction) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, taskFlowAction: taskFlowAction)
    viewController.bindTo(with: viewModel)
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToIdeaBoxTaskList() -> FlowContributors {
    let viewController = IdeaBoxTaskListViewController()
    let viewModel = IdeaBoxTaskListViewModel(services: services)
    viewController.bindTo(with: viewModel)
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToTaskType(taskType: TaskType?) -> FlowContributors {
    let viewController = TaskTypeViewController()
    let viewModel = TaskTypeViewModel(services: services, taskType: taskType)
    viewController.bindTo(with: viewModel)
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }
  
}

