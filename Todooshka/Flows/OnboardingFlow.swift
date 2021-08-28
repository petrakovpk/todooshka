//
//  OnboardingFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.07.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import UIKit


class OnboardingFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
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
        case .authIsRequired:
            return navigateToAuthScreen()
        case .onboardingIsRequired:
            return navigateToOnboardingScreen()
        case .onboardingIsCompleted:
            return dismissOnboardingScreen()
        default:
            return .none
        }
    }
    
    private func navigateToOnboardingScreen() -> FlowContributors {
        let viewController = OnboardingViewController()
        let viewModel = OnboardingViewModel(services: services)
        viewController.bindTo(with: viewModel)
        rootViewController.navigationBar.isHidden = true 
        rootViewController.setViewControllers([viewController], animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
    private func navigateToAuthScreen() -> FlowContributors {
        
        let authFlow = AuthFlow(withServices: services)
        
        Flows.use(authFlow, when: .created) { [unowned self] root in
            DispatchQueue.main.async {
                root.modalPresentationStyle = .fullScreen
                rootViewController.present(root, animated: true)
            }
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: authFlow,
                                                 withNextStepper: OneStepper(withSingleStep: AppStep.authIsRequired)))
        
        
    }
    
    private func dismissOnboardingScreen() -> FlowContributors {
        rootViewController.dismiss(animated: true)
        return .end(forwardToParentFlowWithStep: AppStep.onboardingIsCompleted)
    }
}
