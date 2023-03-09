//
//  WorkplaceFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.01.2023.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class WorkplaceFlow: Flow {
  var root: Presentable {
    rootViewController
  }
  
  private let rootViewController = UINavigationController()
  private let services: AppServices

  // MARK: - Init
  init(withServices services: AppServices) {
    self.services = services
  }

  deinit {
    print("\(type(of: self)): \(#function)")
  }

  // MARK: - Flow Contributors
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    switch step {
    case .workplaceIsRequired:
      return navigateToWorkplace()
    default:
      return .none
    }
  }
  
  private func navigateToWorkplace() -> FlowContributors {
    
    let viewController = WorklplaceViewController()
    let viewModel = WorklplaceViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    
    let mainTaskListFlow = MainTaskListFlow(withServices: self.services)
    let mainCalendarFlow = CalendarFlow(withServices: self.services)
    
    Flows.use(mainTaskListFlow, mainCalendarFlow, when: .ready) { mainTaskListRoot, mainCalendarRoot in
      viewController.nestedViewControllers = [mainTaskListRoot, mainCalendarRoot]
    }
    
    return .multiple(
      flowContributors: [
        .contribute(withNextPresentable: mainTaskListFlow,
                    withNextStepper: OneStepper(withSingleStep: AppStep.mainTaskListIsRequired),
                    allowStepWhenDismissed: true),
        .contribute(withNextPresentable: mainCalendarFlow,
                    withNextStepper: OneStepper(withSingleStep: AppStep.calendarIsRequired),
                    allowStepWhenDismissed: true)])
  }
  
}

