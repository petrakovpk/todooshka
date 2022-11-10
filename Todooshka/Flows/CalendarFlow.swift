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

  // swiftlint:disable cyclomatic_complexity
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    switch step {
      // Auth
    case .authIsRequired:
      return navigateToAuthFlow()

      // User ProfileIe
    case .calendarIsRequired:
      return navigateToCalendar()

      // Changing
    case .changingNameIsRequired:
      return navigateToChangingName()
    case .changingGenderIsRequired:
      return navigateToChangingGender()
    case .changingBirthdayIsRequired:
      return navigateToChangingBirthday()
    case .changingEmailIsRequired:
      return navigateToChangingEmail()
    case .changingPhoneIsRequired:
      return navigateToChangingPhone()
    case .changingPasswordIsRequired:
      return navigateToChangingPassword()

    case .supportIsRequired:
      return navigateToSupport()

    case .deleteAccountIsRequired:
      return navigateToDeleteAccount()

      // Task
    case .createPlannedTaskIsRequired(let planned):
      return navigateToTask(planned: planned)
    case .showTaskIsRequired(let task):
      return navigateToTask(taskUID: task.UID)
    case .taskProcessingIsCompleted:
      return navigateBack()

      // Task List
    case .completedTaskListIsRequired(let date):
      return navigateToCompletedTaskList(date: date)
    case .deletedTaskListIsRequired:
      return navigateToDeletedTaskList()
    case .taskListIsCompleted:
      return navigateBack()

      // Deleted Task Type List
    case .deletedTaskTypeListIsRequired:
      return navigateToDeletedTaskTypeList()

      // Planned
    case .plannedTaskListIsRequired(let date):
      return navigateToPlannedTaskList(date: date)

      // Diamond
    case .diamondIsRequired:
      return navigateToDiamond()

      // Feather
    case .featherIsRequired:
      return navigateToFeather()

    case .kindOfTaskWithBird(let birdUID):
      return navigateToKindOfTaskForBird(birdUID: birdUID)

      // Logout
    case .logoutIsRequired:
      return endUserProfileFlow()

      // Navigate Back
    case .navigateBack:
      return navigateBack()

      // User Settings
    case .settingsIsRequired:
      return navigateToSettings()

      // Bird
    case .showBirdIsRequired(let bird):
      return navigateToBird(bird: bird)

      // Shop
    case .shopIsRequired:
      return navigateToShop()
    case .shopIsCompleted:
      return navigateBackFromShop()

      // SyncIsRequired
    case .syncDataIsRequired:
      return navigateToSyncData()

      // Task Type List
    case .kindsOfTaskListIsRequired:
      return navigateToTaskTypesList()

    case .userProfileIsRequired:
      return navigateToUserProfile()

    default:
      return .none
    }
  }

  private func navigateToCalendar() -> FlowContributors {
    let viewController = CalendarViewController()
    let userProfileViewModel = CalendarViewModel(services: services)
    let branchSceneModel = BranchSceneModel(services: services)
    viewController.viewModel = userProfileViewModel
    viewController.sceneModel = branchSceneModel
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: userProfileViewModel))
  }

  private func navigateToSettings() -> FlowContributors {
    let viewController = SettingsViewController()
    let viewModel = SettingsViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToCompletedTaskList(date: Date) -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: .completed(date: date))
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToPlannedTaskList(date: Date) -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: .planned(date: date))
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToDeletedTaskList() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: .deleted)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToDeletedTaskTypeList() -> FlowContributors {
    let viewController = KindOfTaskListDeletedViewController()
    let viewModel = KindOfTaskListDeletedViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToKindOfTaskForBird(birdUID: String) -> FlowContributors {
    let viewController = KindOfTaskListForBirdViewController()
    let viewModel = KindOfTaskListForBirdViewModel(services: services, birdUID: birdUID)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTaskTypesList() -> FlowContributors {
    let viewController = KindOfTaskListViewController()
    let viewModel = KindOfTaskListViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToSyncData() -> FlowContributors {
    let viewController = SyncDataViewController()
    let viewModel = SyncDataViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToIdeaBoxTaskList() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, mode: .idea)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
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

  private func navigateToSupport() -> FlowContributors {
    let viewController = SupportViewController()
    let viewModel = SupportViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToDeleteAccount() -> FlowContributors {
    let viewController = DeleteAccountViewController()
    let viewModel = DeleteAccountViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTask(taskUID: String) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, taskUID: taskUID)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTask(planned: Date) -> FlowContributors {
    let viewController = TaskViewController()
    let viewModel = TaskViewModel(services: services, taskUID: UUID().uuidString, status: .planned, planned: planned)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToFeather() -> FlowContributors {
    let viewController = FeatherViewController()
    let viewModel = FeatherViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToDiamond() -> FlowContributors {
    let viewController = DiamondViewController()
    let viewModel = DiamondViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToUserProfile() -> FlowContributors {
    let viewController = UserProfileViewController()
    let viewModel = UserProfileViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateBackFromShop() -> FlowContributors {
    rootViewController.tabBarController?.tabBar.isHidden = false
    rootViewController.popViewController(animated: true)
    return .none
  }

  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }

  func endUserProfileFlow() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .end(forwardToParentFlowWithStep: AppStep.logoutIsRequired)
  }

  private func navigateToChangingName() -> FlowContributors {
    let viewController = ChangeNameViewContoller()
    let viewModel = ChangeNameViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToChangingGender() -> FlowContributors {
    let viewController = ChangeGenderViewController()
    let viewModel = ChangeGenderViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToChangingBirthday() -> FlowContributors {
    let viewController = ChangeBirthdayViewController()
    let viewModel = ChangeBirthdayViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToChangingPhone() -> FlowContributors {
    let viewController = SetPhoneViewController()
    let viewModel = SetPhoneViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToChangingEmail() -> FlowContributors {
    let viewController = SetEmailViewController()
    let viewModel = SetEmailViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToChangingPassword() -> FlowContributors {
    let viewController = ChangePasswordViewController()
    let viewModel = ChangePasswordViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
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
  // swiftlint:enable cyclomatic_complexity
}
