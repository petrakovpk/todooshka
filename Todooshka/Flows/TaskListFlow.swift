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
  // MARK: - Properties
  var root: Presentable {
    return self.rootViewController
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
      // Main Task List Is Required
    case .mainTaskListIsRequired:
      return navigateToTaskList()

      // Overdued Task List Is Required
    case .overduedTaskListIsRequired:
      return navigateToOverdueTaskFlow()

      // Idea Task List Is Required
    case .ideaTaskListIsRequired:
      return navigateToIdeaBoxTaskList()

    case .createKindOfTaskIsRequired:
      return navigateToCreateTaskType()

    case .showKindOfTaskIsRequired(let kindOfTask):
      return navigateToShowTaskType(kindOfTask: kindOfTask)

    case .createTaskIsRequired:
      return navigateToTask()
    case .createIdeaTaskIsRequired:
      return navigateToIdeaTask()
    case .showTaskIsRequired(let task):
      return navigateToTask(taskUID: task.UID)

    case .kindsOfTaskListIsRequired:
      return navigateToTaskTypesList()

    case .removeTaskIsRequired:
      return navigateToRemoveConfirmation()

    case .navigateBack,
        .taskProcessingIsCompleted,
        .taskListIsCompleted:
      return navigateBack()

    default:
      return .none
    }
  }

  private func navigateToTaskList() -> FlowContributors {
    let viewController = MainTaskListViewController()
    let mainTaskListSceneModel = NestSceneModel(services: services)
    let mainTaskListViewModel = MainTaskListViewModel(services: services)
    let taskListViewModel = TaskListViewModel(services: services, mode: .main)
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

  private func navigateToTaskTypesList() -> FlowContributors {
    let viewController = KindOfTaskListViewController()
    let viewModel = KindOfTaskListViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTask(taskUID: String) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, taskUID: taskUID )
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTask() -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, taskUID: UUID().uuidString)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToIdeaTask() -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, taskUID: UUID().uuidString, status: .idea, planned: nil)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
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

  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }
}
