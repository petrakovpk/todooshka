//
//  AppFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import Foundation
import UIKit
import RxFlow

class AppFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(true, animated: false)
        return viewController
    }()
    
    private let services: AppServices
    
    //MARK: - Init
    init(services: AppServices) {
        self.services = services
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    //MARK: - Navigate
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .OnboardingIsRequired:
            return navigateToOnboardingFlow()
        case .OnboardingIsCompleted:
            return navigateToTabBarScreen()
        default:
            return .none
        }
    }
    
    //MARK: - Navigate func
    private func navigateToOnboardingFlow() -> FlowContributors {
        let viewController = OnboardingViewController()
        let viewModel = OnboardingViewModel(services: services)
        viewController.viewModel = viewModel
        rootViewController.navigationBar.isHidden = true
        rootViewController.setViewControllers([viewController], animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
        
    }
    
    private func navigateToTabBarScreen() -> FlowContributors {
                
        let tabBarFlow = TabBarFlow(withServices: services)

        Flows.use(tabBarFlow, when: .created) { [unowned self] root in
            self.rootViewController.setViewControllers([root], animated: false)
        }

        return .one(flowContributor: .contribute(withNextPresentable: tabBarFlow,
                                                 withNextStepper: OneStepper(withSingleStep: AppStep.TabBarIsRequired)))
    }
}
