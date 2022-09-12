//
//  CalendarFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class CalendarFlow: Flow {
  
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
      
      // Auth
    case .AuthIsRequired:
      return navigateToAuthFlow()
      
      // User ProfileIe
    case .CalendarIsRequired:
      return navigateToCalendar()
      
      // Task
    case .CreateTaskIsRequired(let status, let date):
      return navigateToTask(taskFlowAction: .create(status: status, closed: date))
    case .ShowTaskIsRequired(let task):
      return navigateToTask(taskFlowAction: .show(task: task) )
    case .TaskProcessingIsCompleted:
      return navigateBack()
      
      // Task List
    case .CompletedTaskListIsRequired(let date):
      return navigateToCompletedTaskList(date: date)
    case .DeletedTaskListIsRequired:
      return navigateToDeletedTaskList()
    case .TaskListIsCompleted:
      return navigateBack()
      
      // Deleted Task Type List
    case .DeletedTaskTypeListIsRequired:
      return navigateToDeletedTaskTypeList()
    case .DeletedTaskTypeListIsCompleted:
      return navigateBack()
      
      // Task Type List
    case .TaskTypesListIsRequired:
      return navigateToTaskTypesList()
    case .TaskTypesListIsCompleted:
      return navigateBack()
      
      // User Settings
    case .SettingsIsRequired:
      return navigateToSettings()
    case .SettingsIsCompleted:
      return navigateBack()
      
      // Shop
    case .ShopIsRequired:
      return navigateToShop()
    case .ShopIsCompleted:
      return navigateBack()
      
      // Bird
    case .ShowBirdIsRequired(let bird):
      return navigateToBird(bird: bird)
    case .ShowBirdIsCompleted:
      return navigateBack()
      
      // Feather
    case .FeatherIsRequired:
      return navigateToFeather()
    case .FeatherIsCompleted:
      return navigateBack()
      
      // Diamond
    case .DiamondIsRequired:
      return navigateToDiamond()
    case .DiamondIsCompleted:
      return navigateBack()
      
      // Logout
    case .LogoutIsRequired:
      return endUserProfileFLow()
      
    case .UserProfileIsRequired:
      return navigateToUserProfile()
      
      // Navigate Back
    case .NavigateBack:
      return navigateBack()
      
      // Changing
    case .ChangingNameIsRequired:
      return navigateToChangingName()
    case .ChangingGenderIsRequired:
      return navigateToChangingGender()
    case .ChangingBirthdayIsRequired:
      return navigateToChangingBirthday()
    case .ChangingEmailIsRequired:
      return navigateToChangingEmail()
    case .ChangingPhoneIsRequired:
      return navigateToChangingPhone()
    case .ChangingPasswordIsRequired:
      return navigateToChangingPassword()
      
    default:
      return .none
    }
  }
  
  private func navigateToCalendar() -> FlowContributors {
    let viewController = CalendarViewController()
    let userProfileViewModel = CalendarViewModel(services: services)
    let branchSceneModel = BranchSceneModel(services: services)
    viewController.viewModel = userProfileViewModel
    viewController.sceneModel = branchSceneModel
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: userProfileViewModel))
  }
  
  private func navigateToSettings() -> FlowContributors {
    let viewController = SettingsViewController()
    let viewModel = SettingsViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToCompletedTaskList(date: Date) -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: .Completed(date: date))
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToDeletedTaskList() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: .Deleted)
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
    let viewModel = TaskListViewModel(services: services, mode: .Idea)
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
  
  private func navigateToFeather() -> FlowContributors {
    let viewController = FeatherViewController()
    let viewModel = FeatherViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToDiamond() -> FlowContributors {
    let viewController = DiamondViewController()
    let viewModel = DiamondViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToUserProfile() -> FlowContributors {
    let viewController = UserProfileViewController()
    let viewModel = UserProfileViewModel(services: services)
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
  
  private func navigateToChangingName() -> FlowContributors {
    let viewController = ChangeNameViewContoller()
    let viewModel = ChangeNameViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToChangingGender() -> FlowContributors {
    let viewController = ChangeGenderViewController()
    let viewModel = ChangeGenderViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToChangingBirthday() -> FlowContributors {
    let viewController = ChangeBirthdayViewController()
    let viewModel = ChangeBirthdayViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToChangingPhone() -> FlowContributors {
    let viewController = ChangePhoneViewController()
    let viewModel = ChangePhoneViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToChangingEmail() -> FlowContributors {
    let viewController = ChangeEmailViewController()
    let viewModel = ChangeEmailViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToChangingPassword() -> FlowContributors {
    let viewController = ChangePasswordViewController()
    let viewModel = ChangePasswordViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  
  private func navigateToAuthFlow() -> FlowContributors {
    
    let authFlow = AuthFlow(withServices: services)
    
    Flows.use(authFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .automatic
        rootViewController.present(root, animated: true)
      }
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: authFlow,
        withNextStepper: OneStepper(
          withSingleStep: AppStep.AuthIsRequired
        )
      )
    )
  }
  
}

