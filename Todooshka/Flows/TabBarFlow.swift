//
//  TabBarFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 19.05.2021.
//

import Foundation
import UIKit
import RxFlow

import RxSwift
import RxCocoa


class TabBarFlow: Flow {
  
  var root: Presentable {
    return self.rootViewController
  }
  
  let rootViewController = TabBarController()
  
  private let services: AppServices
  
  let steps = PublishRelay<Step>()
  
  init(withServices services: AppServices) {
    self.services = services
  }
  
  deinit {
    print("\(type(of: self)): \(#function)")
  }
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .TabBarIsRequired:
      return navigateToTabBar()
    case .CreateTaskIsRequired:
      return navigateToTaskFlow()
    default:
      return .none
    }
  }
  
  private func navigateToTaskFlow() -> FlowContributors {
    
    let taskFlow = TaskFlow(withServices: services)
    
    Flows.use(taskFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .automatic
        rootViewController.present(root, animated: true)
      }
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: taskFlow,
        withNextStepper: OneStepper(
          withSingleStep: AppStep.CreateTaskIsRequired
        )
      )
    )
  }
  
  
  private func navigateToTabBar() -> FlowContributors {
    
    let calendarFlow = CalendarFlow(withServices: self.services)
    let taskListFlow = TaskListFlow(withServices: self.services)
    
    let viewModel = TabBarViewModel(services: services)
    rootViewController.viewModel = viewModel
    rootViewController.bindViewModel()
    
    Flows.use(taskListFlow, calendarFlow, when: .created) { [unowned self] (root1: UINavigationController, root2: UINavigationController) in
      
      let tabBarItem1 = UITabBarItem(title: nil, image: nil, tag: 1)
      let tabBarItem2 = UITabBarItem(title: nil, image: nil, tag: 2)
      
      root1.tabBarItem = tabBarItem1
      root2.tabBarItem = tabBarItem2
      
      root1.navigationBar.isHidden = true
      root2.navigationBar.isHidden = true
      
      self.rootViewController.setViewControllers([root1, root2], animated: false)
    }
    
    return .multiple(flowContributors: [
      .contribute(withNextPresentable: self, withNextStepper: viewModel),
      .contribute(withNextPresentable: taskListFlow, withNextStepper: OneStepper(withSingleStep: AppStep.MainTaskListIsRequired)),
      .contribute(withNextPresentable: calendarFlow, withNextStepper: OneStepper(withSingleStep: AppStep.CalendarIsRequired))
    ])
  }
}
