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
    self.rootViewController
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
    case .mainTaskListIsRequired:
      return navigateToMainTaskList()

    case .overduedTaskListIsRequired:
      return navigateToOverdueTaskFlow()

    case .ideaTaskListIsRequired:
      return navigateToIdeaBoxTaskList()

    case .createKindOfTaskIsRequired:
      return navigateToCreateTaskType()

    case .showKindOfTaskIsRequired(let kindOfTask):
      return navigateToShowTaskType(kindOfTask: kindOfTask)

    case .createTaskIsRequired(let task, let isModal):
      return navigateToTask(task: task, isModal: isModal)
    case .showTaskIsRequired(let task):
      return navigateToTask(task: task, isModal: false )

    case .kindsOfTaskListIsRequired:
      return navigateToKindOfTaskList()

    case .removeTaskIsRequired:
      return navigateToRemoveConfirmation()
      
    case .shopIsRequired:
      return navigateToShop()

    case .navigateBack,
        .taskProcessingIsCompleted,
        .taskListIsCompleted:
      return navigateBack()

    default:
      return .none
    }
  }

  private func navigateToMainTaskList() -> FlowContributors {
    let viewController = MainTaskListViewController()
    let mainSceneModel = MainSceneModel(services: services)
    let mainTaskListViewModel = MainTaskListViewModel(services: services)
    let taskListViewModel = TaskListViewModel(services: services, mode: .main)
    let calendarViewModel = CalendarViewModel(services: services)
    viewController.mainSceneModel = mainSceneModel
    viewController.mainViewModel = mainTaskListViewModel
    viewController.taskListViewModel = taskListViewModel
    viewController.calendarViewModel = calendarViewModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.tabBarController?.tabBar.isHidden = false
    rootViewController.pushViewController(viewController, animated: false)
    return .one(
      flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: CompositeStepper(steppers: [mainTaskListViewModel, taskListViewModel, calendarViewModel])
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
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: alertFlow,
        withNextStepper: OneStepper(withSingleStep: AppStep.removeTaskIsRequired)))
  }

  private func navigateToOverdueTaskFlow() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: .overdued)
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
  
  
  private func navigateToIdeaBoxTaskList() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: .idea)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToCreateTaskType() -> FlowContributors {
    let viewController = KindOfTaskViewController()
    let viewModel = KindOfTaskViewModel(services: services, kindOfTaskUID: UUID().uuidString )
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToShowTaskType(kindOfTask: KindOfTask) -> FlowContributors {
    let viewController = KindOfTaskViewController()
    let viewModel = KindOfTaskViewModel(services: services, kindOfTaskUID: kindOfTask.UID )
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToShop() -> FlowContributors {
    let viewController = ShopViewController()
    let viewModel = ShopViewModel(services: services)
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
