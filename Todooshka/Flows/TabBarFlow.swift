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
    case .tabBarIsRequired:
      return navigateToTabBar()
    case .createTaskIsRequired:
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
          withSingleStep: AppStep.createTaskIsRequired(task: Task(UID: UUID().uuidString, status: .inProgress))
        )
      )
    )
  }

  private func navigateToTabBar() -> FlowContributors {
    let feedFlow = FeedFlow(withServices: self.services)
    let marketplaceFlow = MarketplaceFlow(withServices: self.services)
    let emptyFlow = EmptyFlow()
    let taskListFlow = TaskListFlow(withServices: self.services)
    let calendarFlow = CalendarFlow(withServices: self.services)

    let viewModel = TabBarViewModel(services: services)
    rootViewController.viewModel = viewModel
    rootViewController.bindViewModel()

    Flows.use(
      feedFlow,
      marketplaceFlow,
      emptyFlow,
      taskListFlow,
      calendarFlow,
      when: .created
    ) { [unowned self] ( root1: UINavigationController, root2: UINavigationController, root3: UINavigationController, root4: UINavigationController, root5: UINavigationController ) in
      let tabBarItem1 = UITabBarItem(title: nil, image: nil, tag: 1)
      let tabBarItem2 = UITabBarItem(title: nil, image: nil, tag: 2)
      let tabBarItem3 = UITabBarItem(title: nil, image: nil, tag: 3)
      let tabBarItem4 = UITabBarItem(title: nil, image: nil, tag: 4)
      let tabBarItem5 = UITabBarItem(title: nil, image: nil, tag: 5)

      root1.tabBarItem = tabBarItem1
      root2.tabBarItem = tabBarItem2
      root3.tabBarItem = tabBarItem3
      root4.tabBarItem = tabBarItem4
      root5.tabBarItem = tabBarItem5

      root1.navigationBar.isHidden = true
      root2.navigationBar.isHidden = true
      root3.navigationBar.isHidden = true
      root4.navigationBar.isHidden = true
      root5.navigationBar.isHidden = true
      
      root3.tabBarItem.isEnabled = false

      self.rootViewController.setViewControllers([root1, root2, root3, root4, root5], animated: false)
    }

    return .multiple(flowContributors: [
      .contribute(withNextPresentable: self, withNextStepper: viewModel),
      .contribute(withNextPresentable: feedFlow, withNextStepper: OneStepper(withSingleStep: AppStep.feedIsRequired)),
      .contribute(withNextPresentable: marketplaceFlow, withNextStepper: OneStepper(withSingleStep: AppStep.marketplaceIsRequired)),
      .contribute(withNextPresentable: emptyFlow, withNextStepper: OneStepper(withSingleStep: AppStep.navigateBack)),
      .contribute(withNextPresentable: taskListFlow, withNextStepper: OneStepper(withSingleStep: AppStep.mainTaskListIsRequired)),
      .contribute(withNextPresentable: calendarFlow, withNextStepper: OneStepper(withSingleStep: AppStep.calendarIsRequired))
    ])
  }
}
