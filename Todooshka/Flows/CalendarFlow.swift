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
      
    case .authIsRequired:
      return navigateToAuthFlow()
      
//    case .createTaskIsRequired(let task, let isModal):
//      return navigateToTask(task: task, isModal: isModal)
//    case .openTaskIsRequired(let task):
//      return navigateToTask(task: task, isModal: false)
//    case .addPhotoIsRequired(let task):
//      return navigateToImagePickerFlow(task: task)
//    case .resultPreviewIsRequired(let task):
//      return navigateToResultPreview(task: task)
      
    case .shopIsRequired:
      return navigateToShop()
    case .showBirdIsRequired(let bird):
      return navigateToBird(bird: bird)
      
    case .settingsIsRequired:
      return navigateToSettings()
      
    case .navigateBack:
      return navigateBack()
    default:
      return .none
    }
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

  private func navigateToResultPreview(task: Task) -> FlowContributors {
    let viewController = ResultPreviewViewController()
    let viewModel = ResultPreviewViewModel(services: services, task: task)
    viewController.viewModel = viewModel
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
  
  private func navigateToBird(bird: Bird) -> FlowContributors {
    let viewController = BirdViewController()
    let viewModel = BirdViewModel(birdUID: bird.UID, services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
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
  
  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
    }
}
