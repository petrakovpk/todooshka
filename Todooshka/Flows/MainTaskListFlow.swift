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
    rootViewController
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
      // TASK LIST
    case .mainTaskListIsRequired:
      return navigateToMainTaskList()
    case .ideaTaskListIsRequired:
      return navigateToTaskList(mode: .idea)
    case .overduedTaskListIsRequired:
      return navigateToTaskList(mode: .overdued)
      
      // TASK
    case .createTaskIsRequired(let task, let isModal):
      return navigateToTask(task: task, isModal: isModal)
    case .showTaskIsRequired(let task):
      return navigateToTask(task: task, isModal: false )
    case .addPhotoIsRequired(let task):
      return navigateToImagePickerFlow(task: task)
    case .resultPreviewIsRequired(let task):
      return navigateToResultPreview(task: task)
      
      // KIND OF TASK LIST
    case .kindsOfTaskListIsRequired:
      return navigateToKindOfTaskList()
      
      // KIND OF TASK
    case .createKindOfTaskIsRequired:
      return navigateToCreateKindOfTask()
    case .showKindOfTaskIsRequired(let kindOfTask):
      return navigateToShowKindOfTask(kindOfTask: kindOfTask)
    
      // BACK AND DISMISS
    case .navigateBack,
        .taskProcessingIsCompleted,
        .taskListIsCompleted:
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
  
  private func navigateToImagePickerFlow(task: Task) -> FlowContributors {
    let pickerFlow = ImagePickerFlow(withServices: services)
    
    Flows.use(pickerFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .automatic
        rootViewController.present(root, animated: true)
      }
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: pickerFlow,
        withNextStepper: OneStepper(
          withSingleStep: AppStep.addPhotoIsRequired(task: task)
        )
      )
    )
  }
  
  private func navigateToResultPreview(task: Task) -> FlowContributors {
    let viewController = ResultPreviewViewController()
    let viewModel = ResultPreviewViewModel(services: services, task: task)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToTaskList(mode: TaskListMode) -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: mode)
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
  
  private func navigateToCreateKindOfTask() -> FlowContributors {
    let viewController = KindOfTaskViewController()
    let viewModel = KindOfTaskViewModel(services: services, kindOfTaskUID: UUID().uuidString )
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToShowKindOfTask(kindOfTask: KindOfTask) -> FlowContributors {
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
  
  private func dismiss() -> FlowContributors {
    rootViewController.dismiss(animated: true)
    return .none
  }
}

