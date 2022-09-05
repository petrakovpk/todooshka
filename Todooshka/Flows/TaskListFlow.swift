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
      
      // Main Task List Is Required
    case .MainTaskListIsRequired:
      return navigateToTaskList()
      
      // Overdued Task List Is Required
    case .OverduedTaskListIsRequired:
      return navigateToOverdueTaskFlow()
      
      // Idea Task List Is Required
    case .IdeaTaskListIsRequired:
      return navigateToIdeaBoxTaskList()
      
      // Task List Is Completed
    case .TaskListIsCompleted:
      return navigateBack()
      
    case .CreateTaskTypeIsRequired:
      return navigateToCreateTaskType()
      
    case .ShowTaskTypeIsRequired(let type):
      return navigateToShowTaskType(type: type)
      
    case .TaskTypeProcessingIsCompleted:
      return navigateBack()
      
    case .CreateTaskIsRequired(let status, let date):
      return navigateToTask(taskFlowAction: .create(status: status, closed: date))
    case .ShowTaskIsRequired(let task):
      return navigateToTask(taskFlowAction: .show(task: task))
      
    case .TaskProcessingIsCompleted:
      return navigateBack()
      
    case .TaskTypesListIsRequired:
      return navigateToTaskTypesList()
      
    case .TaskTypesListIsCompleted:
      return navigateBack()
      
    case .RemoveTaskIsRequired:
      return navigateToRemoveConfirmation()
      
    default:
      return .none
    }
  }
  
  private func navigateToTaskList() -> FlowContributors {
    let viewController = MainTaskListViewController()
    let mainTaskListSceneModel = NestSceneModel(services: services)
    let mainTaskListViewModel = MainTaskListViewModel(services: services)
    let taskListViewModel = TaskListViewModel(services: services, mode: .Main)
    viewController.sceneModel = mainTaskListSceneModel
    viewController.viewModel = mainTaskListViewModel
    viewController.listViewModel = taskListViewModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.tabBarController?.tabBar.isHidden = false
    rootViewController.pushViewController(viewController, animated: false)
    return .one(
      flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: CompositeStepper(steppers: [mainTaskListViewModel, taskListViewModel])
      )
    )
  }
  
  private func navigateToRemoveConfirmation() -> FlowContributors {
    let alertFlow = AlertFlow(withServices: services)
    
    Flows.use(alertFlow, when: .created) { [self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .fullScreen
        rootViewController.present(root, animated: true)
      }
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: alertFlow,
                                             withNextStepper: OneStepper(withSingleStep: AppStep.RemoveTaskIsRequired)))
  }
  
  private func navigateToOverdueTaskFlow() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: .Overdued)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToTaskTypesList() -> FlowContributors {
    let viewController = TaskTypesListViewController()
    let viewModel = TaskTypesListViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToTask(taskFlowAction: TaskFlowAction) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, taskFlowAction: taskFlowAction)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToIdeaBoxTaskList() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: .Idea)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
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
  
}

