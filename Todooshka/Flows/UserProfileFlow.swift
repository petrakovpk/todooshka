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
      
    case .UserProfileIsRequired:
      return navigateToUserProfile()
      
    case .CreateTaskIsRequired(let status, let date):
      return navigateToTask(taskFlowAction: .create(status: status, closed: date))
    case .ShowTaskIsRequired(let task):
      return navigateToTask(taskFlowAction: .show(task: task) )
      
    case .TaskProcessingIsCompleted:
      return navigateBack()
      
    case .DeletedTaskListIsRequired:
      return navigateToDeletedTaskList()
    case .CompletedTaskListIsRequired(let date):
      return navigateToCompletedTaskList(date: date)
    
    case .TaskListIsCompleted:
      return navigateBack()
    
    case .DeletedTaskTypeListIsRequired:
      return navigateToDeletedTaskTypeList()
    
    case .DeletedTaskTypeListIsCompleted:
      return navigateBack()
      
    case .TaskTypesListIsRequired:
      return navigateToTaskTypesList()
      
    case .TaskTypesListIsCompleted:
      return navigateBack()
      
    case .UserSettingsIsRequired:
      return navigateToSettings()
    
    case .UserSettingsIsCompleted:
      return navigateBack()
      
    case .ShopIsRequired:
      return navigateToShop()
      
    case .ShopIsCompleted:
      return navigateBack()
      
    case .ShowBirdIsRequired(let bird):
      return navigateToBird(bird: bird)
      
    case .ShowBirdIsCompleted:
      return navigateBack()
      
    case .ShowPointsIsRequired:
      return navigateToScore()
      
    case .ShowPointsIsCompleted:
      return navigateBack()
      
    case .LogoutIsRequired:
      return endUserProfileFLow()
      
    default:
      return .none
    }
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
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToCompletedTaskList(date: Date) -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, type: .Completed(date: date))
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToDeletedTaskList() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, type: .Deleted)
    viewController.viewModel = viewModel
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
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToIdeaBoxTaskList() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, type: .Idea)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToShop() -> FlowContributors {
    let viewController = ShopViewController()
    let viewModel = ShopViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToBird(bird: Bird) -> FlowContributors {
    let viewController = BirdViewController()
    let viewModel = BirdViewModel(bird: bird, services: services)
    viewController.viewModel = viewModel
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
  
  private func navigateToScore() -> FlowContributors {
    let viewController = ScoreViewController()
    let viewModel = ScoreViewModel(services: services)
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
    return .end(forwardToParentFlowWithStep: AppStep.LogoutIsRequired)
  }
  
}

