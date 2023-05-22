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
    self.rootViewController
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
    case .calendarIsRequired:
      return navigateToCalendar()
      
    case .dayTaskListIsRequired(let date):
      return navigateToDayTaskList(date: date)
    case .openTaskIsRequired(let task, let taskListMode):
      return navigateToTask(task: task, taskListMode: taskListMode)
      
    case .shopIsRequired:
      return navigateToShop()
    case .showBirdIsRequired(let bird):
      return navigateToBird(bird: bird)
      
    case .settingsIsRequired:
      return navigateToSettings()
    case .authIsRequired:
      return navigateToAuthFlow()
    case .accountSettingsIsRequired:
      return navigateToUserProfile()
    case .deletedTaskListIsRequired:
      return navigateToDeletedTaskList()
    case .deletedKindListIsRequired:
      return navigateToDeletedKindList()
    case .supportIsRequired:
      return navigateToSupport()
      
    case .navigateBack:
      return navigateBack()
    default:
      return .none
    }
  }
  
  private func navigateToCalendar() -> FlowContributors {
    let viewController = CalendarViewController()
    let viewModel = CalendarViewModel(services: services)
    let sceneModel = MainCalendarSceneModel(services: services)
    viewController.viewModel = viewModel
    viewController.sceneModel = sceneModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToDayTaskList(date: Date) -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, taskListMode: .day(date: date))
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToTask(task: Task, taskListMode: TaskListMode) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, task: task, taskListMode: taskListMode)
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
  
  private func navigateToSettings() -> FlowContributors {
    let viewController = SettingsViewController()
    let viewModel = SettingsViewModel(services: services)
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
          withSingleStep: AppStep.authIsRequired
        )
      )
    )
  }
  
  private func navigateToUserProfile() -> FlowContributors {
    let viewController = SettingsAccountViewController()
    let viewModel = SettingsAccountViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToDeletedTaskList() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, taskListMode: .deleted)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToDeletedKindList() -> FlowContributors {
    let viewController = KindListViewController()
    let viewModel = KindListViewModel(services: services, kindListMode: .deleted)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToSupport() -> FlowContributors {
    let viewController = SupportViewController()
    let viewModel = SupportViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  
  private func navigateToBird(bird: Bird) -> FlowContributors {
    let viewController = BirdViewController()
    let viewModel = BirdViewModel(birdUID: bird.UID, services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }
}
