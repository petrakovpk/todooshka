//
//  TaskFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 19.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class TaskFlow: Flow {
    
    //MARK: - Properties
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController()
    private let services: AppServices
    
    //MARK: - Init
    init(withServices services: AppServices) {
        self.services = services
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    //MARK: - Flow Contributors
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .createTaskIsRequired:
            return navigateToTask(taskFlowAction: .createTask(status: .created, closedDate: nil) )
        case .taskTypesListIsRequired:
            return navigateToTaskTypesList()
        case .taskTypesListIsCompleted:
            return navigateBackToTask()
        case .taskProcessingIsCompleted:
            return dismissTask()
        default:
            return .none
        }
    }
    
    private func navigateToTask(taskFlowAction: TaskFlowAction) -> FlowContributors {
        let viewController = TaskViewController()
        let viewModel = TaskViewModel(services: services, taskFlowAction: taskFlowAction)
        viewController.bindTo(with: viewModel)
        rootViewController.navigationBar.isHidden = true
        rootViewController.pushViewController(viewController, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
    private func navigateToTaskTypesList() -> FlowContributors {
        let viewController = TaskTypesListViewController()
        let viewModel = TaskTypesListViewModel(services: services)
        viewController.bindTo(with: viewModel)
        rootViewController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
    private func navigateBackToTask() -> FlowContributors {
        rootViewController.popViewController(animated: true)
        return .none
    }
    
    private func dismissTask() -> FlowContributors {
        rootViewController.dismiss(animated: true)
        return .none
    }
    
}
