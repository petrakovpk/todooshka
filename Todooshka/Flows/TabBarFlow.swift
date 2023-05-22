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
  
  private let rootViewController = TabBarController()
  private let services: AppServices
  
  public let steps = PublishRelay<Step>()
  
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
      
    case .authIsRequired:
      return navigateToAuth()
      
    case .addTabBarPresentationIsRequired:
      return navigateToAddSheet()
      
    case .openTaskIsRequired(let task, let taskListMode):
      return navigateToTaskFlow(task: task, taskListMode: taskListMode)
    case .publicationIsRequired(let publication):
      return navigateToPublicationFlow(publication: publication)
      
    default:
      return .none
    }
  }
  
  private func navigateToAddSheet() -> FlowContributors {
    let viewController = AddPresentationViewController()
    let viewModel = AddPresentationViewModel(services: services)
    viewController.viewModel = viewModel
    
    if let sheet = viewController.sheetPresentationController {
      let multiplier = 0.25
      let fraction = UISheetPresentationController.Detent.custom { context in
        UIScreen.main.bounds.height * multiplier
      }
      sheet.detents = [fraction, .medium()]
    }
    
    rootViewController.tabBarController?.tabBar.isHidden = false
    rootViewController.present(viewController, animated: true)
    
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToAuth() -> FlowContributors {
    let authFlow = AuthFlow(withServices: services)
    
    Flows.use(authFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .automatic
        rootViewController.dismiss(animated: true)
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
  
  private func navigateToTaskFlow(task: Task, taskListMode: TaskListMode) -> FlowContributors {
    let taskFlow = TaskFlow(withServices: services)
    
    Flows.use(taskFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .overFullScreen
        rootViewController.dismiss(animated: true)
        rootViewController.present(root, animated: true)
      }
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: taskFlow,
        withNextStepper: OneStepper(
          withSingleStep: AppStep.openTaskIsRequired(task: task, taskListMode: taskListMode)
        )
      )
    )
  }
  
  private func navigateToPublicationFlow(publication: Publication) -> FlowContributors {
    let publicationFlow = PublicationFlow(withServices: services)
    
    Flows.use(publicationFlow, when: .created) { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .overFullScreen
        rootViewController.dismiss(animated: true)
        rootViewController.present(root, animated: true)
      }
    }
    
    return .one(
      flowContributor: .contribute(
        withNextPresentable: publicationFlow,
        withNextStepper: OneStepper(
          withSingleStep: AppStep.publicationEditIsRequired(
            publication: publication,
            publicationImage: nil
          )
        )
      )
    )
  }
  
  private func navigateToTabBar() -> FlowContributors {
    let viewModel = TabBarViewModel(services: services)
    rootViewController.viewModel = viewModel
    rootViewController.bindViewModel()
    
    let funFlow = FunFlow(withServices: services)
    let marketPlaceFlow = MarketplaceFlow(withServices: services)
    let emptyFlow = EmptyFlow()
    let mainTaskListFlow = MainTaskListFlow(withServices: services)
    let profileFlow = UserProfileFlow(withServices: services)
    
    Flows.use(
      funFlow,
      marketPlaceFlow,
      emptyFlow,
      mainTaskListFlow,
      profileFlow,
      when: .created
    ) { [unowned self] ( root1: UINavigationController, root2: UINavigationController, root3: UINavigationController, root4: UINavigationController, root5: UINavigationController) in
      
      let tabBarItem1 = UITabBarItem(
        title: nil,
        image: Icon.crown.image.template.withTintColor(Style.TabBar.Unselected!),
        selectedImage: Icon.crown.image.template.withTintColor(Style.TabBar.Selected!)
      )
      
      let tabBarItem2 = UITabBarItem(
        title: nil,
        image: Icon.cup.image.template.withTintColor(Style.TabBar.Unselected!),
        selectedImage: Icon.cup.image.template.withTintColor(Style.TabBar.Selected!)
      )
      
      let tabBarItem3 = UITabBarItem(
        title: nil,
        image: Icon.plus.image.template.withTintColor(Style.TabBar.Unselected!),
        selectedImage: Icon.plus.image.template.withTintColor(Style.TabBar.Selected!)
      )
      
      let tabBarItem4 = UITabBarItem(
        title: nil,
        image: Icon.clipboardTick.image.template.withTintColor(Style.TabBar.Unselected!),
        selectedImage: Icon.clipboardTick.image.template.withTintColor(Style.TabBar.Selected!)
      )
      
      let tabBarItem5 = UITabBarItem(
        title: nil,
        image: Icon.userSquare.image.template.withTintColor(Style.TabBar.Unselected!),
        selectedImage: Icon.userSquare.image.template.withTintColor(Style.TabBar.Selected!)
      )
      
      root1.tabBarItem = tabBarItem1
      root2.tabBarItem = tabBarItem2
      root3.tabBarItem = tabBarItem3
      root4.tabBarItem = tabBarItem4
      root5.tabBarItem = tabBarItem5
      
      root3.tabBarItem.isEnabled = false
      
      root1.navigationBar.isHidden = true
      root2.navigationBar.isHidden = true
      root3.navigationBar.isHidden = true
      root4.navigationBar.isHidden = true
      root5.navigationBar.isHidden = true
      
      self.rootViewController.setViewControllers([root1, root2, root3, root4, root5], animated: false)
    }
    
    return .multiple(flowContributors: [
      .contribute(withNextPresentable: self, withNextStepper: viewModel),
      .contribute(withNextPresentable: funFlow, withNextStepper: OneStepper(withSingleStep: AppStep.funIsRequired)),
      .contribute(withNextPresentable: marketPlaceFlow, withNextStepper: OneStepper(withSingleStep: AppStep.marketplaceIsRequired)),
      .contribute(withNextPresentable: mainTaskListFlow, withNextStepper: OneStepper(withSingleStep: AppStep.mainTaskListIsRequired)),
      .contribute(withNextPresentable: profileFlow, withNextStepper: OneStepper(withSingleStep: AppStep.profileIsRequired))
      
    ])
  }
}
