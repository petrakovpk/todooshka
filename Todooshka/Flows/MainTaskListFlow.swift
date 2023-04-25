//
//  MainTaskListFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.01.2023.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit
import PhotosUI
import ImagePicker
import YPImagePicker

class MainTaskListFlow: Flow {
  var root: Presentable {
    return rootViewController
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
    case .mainTaskListIsRequired:
      return navigateToMainTaskList()
    
    case .ideaTaskListIsRequired:
      return navigateToTaskList(taskListMode: .idea)
    case .overduedTaskListIsRequired:
      return navigateToTaskList(taskListMode: .overdued)
      
    case .openTaskIsRequired(let task, let taskListMode):
      return navigateToTask(task: task, taskListMode: taskListMode)
      
    case .kindListIsRequired:
      return navigateToKindList()
    case .openKindIsRequired(let kind):
      return navigateToKind(kind: kind)

    case .navigateBack,
        .taskProcessingIsCompleted:
      return navigateBack()

    case .dismiss:
      return dismiss()
      
    default:
      return .none
    }
  }

  private func navigateToMainTaskList() -> FlowContributors {
    let viewController = MainTaskListViewController()
    let viewModel = MainTaskListViewModel(services: services)
    let sceneModel = MainTaskListSceneModel(services: services)
    viewController.viewModel = viewModel
    viewController.sceneModel = sceneModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.tabBarController?.tabBar.isHidden = false
    rootViewController.pushViewController(viewController, animated: false)
    return .one(
      flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: viewModel
      )
    )
  }
  
  private func navigateToTask(task: Task, taskListMode: TaskListMode) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, task: task, taskListMode: taskListMode)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToTaskList(taskListMode: TaskListMode) -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, taskListMode: taskListMode)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToKindList() -> FlowContributors {
    let viewController = KindListViewController()
    let viewModel = KindListViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToKind(kind: Kind) -> FlowContributors {
    let viewController = KindViewController()
    let viewModel = KindViewModel(services: services, kind: kind)
    viewController.viewModel = viewModel
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

