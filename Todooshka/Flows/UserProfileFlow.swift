//
//  UserProfileFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit
import Firebase

class UserProfileFlow: Flow {
  
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
    case .userProfileIsRequired:
      return navigateToUserProfile()
    case .logoutIsRequired:
      return endUserProfileFLow()
      
    case .completedTaskListIsRequired(let date):
      return navigateToCompletedTaskList(date: date)
    case .completedTaskListIsCompleted:
      return navigateBack()
      
    case .deletedTaskListIsRequired:
      return navigateToDeletedTaskList()
    case .deletedTaskListIsCompleted:
      return navigateBack()
      
    case .deletedTaskTypeListIsRequired:
      return navigateToDeletedTaskTypeList()
    case .deletedTaskTypeListIsCompleted:
      return navigateBack()
      
    case .ideaBoxTaskListIsRequired:
      return navigateToIdeaBoxTaskList()
    case .ideaBoxTaskListIsCompleted:
      return navigateBack()
      
    case .createTaskIsRequired(let status, let date):
      return navigateToTask(taskFlowAction: .createTask(status: status, closedDate: date))
    case .showTaskIsRequired(let task):
      return navigateToTask(taskFlowAction: .showTask(task: task) )
      
    case .taskTypesListIsRequired:
      return navigateToTaskTypesList()
    case .taskTypesListIsCompleted:
      return navigateBack()
      
    case .userSettingsIsRequired:
      return navigateToSettings()
    case .userSettingsIsCompleted:
      return navigateBack()
      
    case .taskProcessingIsCompleted:
      return navigateBack()
      
    case .authIsRequired:
      return navigateToAuthFlow()
      
    default:
      return .none
    }
  }
  
  private func navigateToAuthFlow() -> FlowContributors {
    
    let authFlow = AuthFlow(withServices: services)
    
    Flows.use(authFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .fullScreen
        rootViewController.present(root, animated: true)
      }
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: authFlow,
                                             withNextStepper: OneStepper(withSingleStep: AppStep.authIsRequired)))
    
  }
  
  private func navigateToUserProfile() -> FlowContributors {
    let viewController = UserProfileViewController()
    let viewModel = UserProfileViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToSettings() -> FlowContributors {
    let viewController = UserProfileSettingsViewController()
    let viewModel = UserProfileSettingsViewModel(services: services)
    viewController.bindTo(with: viewModel)
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToCompletedTaskList(date: Date) -> FlowContributors {
    let viewController = CompletedTasksListViewController()
    let viewModel = CompletedTasksListViewModel(services: services, date: date )
    viewController.bindTo(with: viewModel)
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToDeletedTaskList() -> FlowContributors {
    let viewController = DeletedTasksListViewController()
    let viewModel = DeletedTasksListViewModel(services: services)
    viewController.bindTo(with: viewModel)
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToDeletedTaskTypeList() -> FlowContributors {
    let viewController = DeletedTaskTypesListViewController()
    let viewModel = DeletedTaskTypesListViewModel(services: services)
    viewController.bindTo(with: viewModel)
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
  
  private func navigateToIdeaBoxTaskList() -> FlowContributors {
    let viewController = IdeaBoxTaskListViewController()
    let viewModel = IdeaBoxTaskListViewModel(services: services)
    viewController.bindTo(with: viewModel)
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToTask(taskFlowAction: TaskFlowAction) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, taskFlowAction: taskFlowAction)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }
  
  func endUserProfileFLow() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .end(forwardToParentFlowWithStep: AppStep.logoutIsRequired)
  }
  
}

