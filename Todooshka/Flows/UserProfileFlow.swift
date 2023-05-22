//
//  ProfileFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.01.2023.
//

import CoreData
import RxCocoa
import RxFlow
import RxSwift
import UIKit
import AnyImageKit

class UserProfileFlow: Flow {
  var root: Presentable {
    self.rootViewController
  }

  private let rootViewController = UINavigationController()
  private let modalRoot = UINavigationController()
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
    case .profileIsRequired:
      return navigateToProfile()
    case .imagePickerIsRequired:
      return navigateToImagePicker()
      
    case .followersIsRequired:
      return navigateToFollowers()
    case .subsriptionsIsRequired:
      return navigateToSubscriptions()
    
    case .settingsIsRequired:
      return navigateToSettings()
    case .accountSettingsIsRequired:
      return navigateToAccountSettings()
    case .authIsRequired:
      return navigateToAuthFlow()
    case .deletedTaskListIsRequired:
      return navigateToDeletedTaskList()
    case .deletedKindListIsRequired:
      return navigateToDeletedKindList()
    case .supportIsRequired:
      return navigateToSupport()
      
    case .publicationIsRequired(let publication):
      return navigateToPublication(publication: publication)
    case .publicationSettingsIsRequired(let publication, let publicationImage):
      return navigateToPublicationSettings(publication: publication, publicationImage: publicationImage)
    case .publicationEditIsRequired(let publication, let publicationImage):
      return navigateToEditPublication(publication: publication, publicationImage: publicationImage)
    case .publicationPublicKindIsRequired(let publication):
      return navigateToPublicKindIsRequired(publication: publication)
      
    case .extUserDataCameraForIsRequired(let extUserData):
      return navigateToCamera(extUserData: extUserData)
    case .extUserDataPhotoLibraryForIsRequired(let extUserData):
      return navigateToImageLibrary(extUserData: extUserData)
      
    case .publicationPhotoLibraryIsRequired(let publication):
      return navigateToImageLibrary(publication: publication)
    
    case .publicationProcesingIsCompleted,
        .navigateBack:
      return navigateBack(tabBarIsHidden: true)
      
    case .publicationEditProcesingIsCompleted:
      return navigateBack(tabBarIsHidden: false)
      
    case .dismiss:
      return dismiss()
    case .dismissAndNavigateBack:
      return dismissAndNavigateBack(tabBarIsHidden: false)
      
    default:
      return .none
    }
  }

  private func navigateToProfile() -> FlowContributors {
    let viewController = UserProfileViewController()
    let viewModel = UserProfileViewModel(services: services)
    
    let publicationsViewController = UserProfilePublicationsViewController()
    let publicationsViewModel = UserProfilePublicationsViewModel(services: services)
    
    let taskListViewController = UserProfileTaskListViewContoller()
    let taskListViewModel = UserProfileTaskListViewModel(services: services)
    
    publicationsViewController.viewModel = publicationsViewModel
    taskListViewController.viewModel = taskListViewModel
    
    viewController.viewControllers = [publicationsViewController, taskListViewController]
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: false)
    return .one(
      flowContributor: .contribute(
        withNextPresentable: viewController,
        withNextStepper: CompositeStepper(steppers: [viewModel, publicationsViewModel, taskListViewModel])
      ))
  }
  
  private func navigateToImagePicker() -> FlowContributors {
    let viewController = UserImagePresentationViewController()
    let viewModel = UserImagePresentationViewModel(services: services)
    viewController.viewModel = viewModel


    if let sheet = viewController.sheetPresentationController {
      let multiplier = 0.35
      let fraction = UISheetPresentationController.Detent.custom { context in
        UIScreen.main.bounds.height * multiplier
      }
      sheet.detents = [fraction, .medium()]
      sheet.prefersGrabberVisible = true
    }
   
    rootViewController.tabBarController?.tabBar.isHidden = false
    rootViewController.present(viewController, animated: true)

    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToPublicKindIsRequired(publication: Publication) -> FlowContributors {
    let viewController = PublicationPublicKindViewController()
    let viewModel = PublicationPublicKindViewModel(services: services, publication: publication)
    viewController.viewModel = viewModel
    
    if let sheet = viewController.sheetPresentationController {
      let multiplier = 0.5
      let fraction = UISheetPresentationController.Detent.custom { context in
        UIScreen.main.bounds.height * multiplier
      }
      sheet.detents = [fraction]
    }
    
    rootViewController.tabBarController?.tabBar.isHidden = false
    rootViewController.present(viewController, animated: true)
    
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToSettings() -> FlowContributors {
    let viewController = SettingsViewController()
    let viewModel = SettingsViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToPublication(publication: Publication) -> FlowContributors {
    let viewController = PublicationViewController()
    let viewModel = PublicationViewModel(services: services, publication: publication, publicationMode: .publication)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToEditPublication(publication: Publication, publicationImage: PublicationImage?) -> FlowContributors {
    let viewController = PublicationEditViewController()
    let viewModel = PublicationEditViewModel(services: services, publication: publication, publicationImage: publicationImage)
    viewController.viewModel = viewModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.dismiss(animated: true)
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToPublicationSettings(publication: Publication, publicationImage: PublicationImage?) -> FlowContributors {
    let viewController = PublicationSettingsViewController()
    let viewModel = PublicationSettingsViewModel(services: services, publication: publication, publicationImage: publicationImage)
    viewController.viewModel = viewModel

    if let sheet = viewController.sheetPresentationController {
      let multiplier = 0.25
      let fraction = UISheetPresentationController.Detent.custom { context in
        UIScreen.main.bounds.height * multiplier
      }
      sheet.prefersGrabberVisible = true
      sheet.detents = [fraction, .medium()]
    }
    
    rootViewController.tabBarController?.tabBar.isHidden = false
    rootViewController.present(viewController, animated: true)

    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToFollowers() -> FlowContributors {
    let viewController = FollowersViewController()
    let viewModel = FollowersViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToSubscriptions() -> FlowContributors {
    let viewController = SubscriptionsViewController()
    let viewModel = SubscriptionsViewModel(services: services)
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
  
  private func navigateToCamera(extUserData: UserExtData) -> FlowContributors {
    var options = CaptureOptionsInfo()
    options.mediaOptions = [.photo]
    options.photoAspectRatio = .ratio1x1
    options.flashMode = .off
    options.preferredPresets = CapturePreset.createPresets(enableHighResolution: true, enableHighFrameRate: true)
    
    let viewController = CameraPickerController(options: options)
    let viewModel = CameraPickerViewModel(services: services, imagePickerMode: .userProfile(extUserData: extUserData))
    viewController.viewModel = viewModel
    viewController.modalPresentationStyle = .fullScreen
    
    rootViewController.dismiss(animated: true)
    rootViewController.present(viewController, animated: true)
    
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToImageLibrary(extUserData: UserExtData) -> FlowContributors {
    var options = PickerOptionsInfo()
    options.selectLimit = 1
    options.selectionTapAction = .openEditor
    options.saveEditedAsset = false
    options.editorOptions = [.photo]
    options.editorPhotoOptions.toolOptions = [.crop]
    options.editorPhotoOptions.cropOptions = [.custom(w: 1, h: 1)]

    let viewController = PhotoLibraryViewController(options: options)
    let viewModel = PhotoLibraryViewModel(services: services, imagePickerMode: .userProfile(extUserData: extUserData))
    viewController.viewModel = viewModel
    viewController.modalPresentationStyle = .fullScreen
    
    rootViewController.dismiss(animated: true)
    rootViewController.present(viewController, animated: true)
    
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToImageLibrary(publication: Publication) -> FlowContributors {
    var options = PickerOptionsInfo()
    options.selectLimit = 1
    options.selectionTapAction = .openEditor
    options.saveEditedAsset = false
    options.editorOptions = [.photo]
    options.editorPhotoOptions.toolOptions = [.crop]
    options.editorPhotoOptions.cropOptions = [.custom(w: 10, h: 15)]

    let viewController = PhotoLibraryViewController(options: options)
    let viewModel = PhotoLibraryViewModel(services: services, imagePickerMode: .publication(publication: publication))
    viewController.viewModel = viewModel
    viewController.modalPresentationStyle = .fullScreen
    
    rootViewController.present(viewController, animated: true)
    
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToAccountSettings() -> FlowContributors {
    let viewController = SettingsAccountViewController()
    let viewModel = SettingsAccountViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToDeletedTaskList() -> FlowContributors {
    let viewController = TaskListViewController()
    let viewModel = TaskListViewModel(services: services, taskListMode: .deleted)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToDeletedKindList() -> FlowContributors {
    let viewController = KindListViewController()
    let viewModel = KindListViewModel(services: services, kindListMode: .deleted)
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
  
  private func navigateBack(tabBarIsHidden: Bool) -> FlowContributors {
    rootViewController.tabBarController?.tabBar.isHidden = tabBarIsHidden
    rootViewController.popViewController(animated: true)
    return .none
  }
  
  private func dismiss() -> FlowContributors {
    rootViewController.dismiss(animated: true)
    return .none
  }
  
  private func dismissWithoutAnimation() -> FlowContributors {
    rootViewController.dismiss(animated: false)
    return .none
  }
  
  private func dismissAndNavigateBack(tabBarIsHidden: Bool) -> FlowContributors {
    rootViewController.tabBarController?.tabBar.isHidden = tabBarIsHidden
    rootViewController.dismiss(animated: true)
    return .one(flowContributor: .forwardToCurrentFlow(withStep: AppStep.navigateBack))
  }
}
