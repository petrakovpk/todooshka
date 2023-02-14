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

class MainCalendarFlow: Flow {
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
    case .mainCalendarIsRequired:
      return navigateToMainCalendar()
      
    case .createTaskIsRequired(let task, let isModal):
      return navigateToTask(task: task, isModal: isModal)
    case .showTaskIsRequired(let task):
      return navigateToTask(task: task, isModal: false)
    case .addPhotoIsRequired(let task):
      return navigateToImagePickerFlow(task: task)
    
    case .shopIsRequired:
      return navigateToShop()
    case .showBirdIsRequired(let bird):
      return navigateToBird(bird: bird)
      
    case .navigateBack:
      return navigateBack()
    default:
      return .none
    }
  }

  private func navigateToMainCalendar() -> FlowContributors {
    let viewController = MainCalendarViewController()
    let viewModel = MainCalendarViewModel(services: services)
    let sceneModel = MainCalendarSceneModel(services: services)
    viewController.viewModel = viewModel
    viewController.sceneModel = sceneModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.tabBarController?.tabBar.isHidden = false
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

  private func navigateToShop() -> FlowContributors {
    let viewController = ShopViewController()
    let viewModel = ShopViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
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
