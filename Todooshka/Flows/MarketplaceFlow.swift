//
//  MarketplaceFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit
import AnyImageKit

class MarketplaceFlow: Flow {
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
    case .marketplaceIsRequired:
      return navigateToMarketplace()
      
    case .authIsRequired:
      return navigateToAuth()
      
    case .searchIsRequired:
      return navigateToSearch()
      
    case .questIsRequired(let quest):
      return navigateToOpenQuest(quest: quest)
    case .questGalleryIsRequired(let quest, let questImage):
      return navigateToQuestGallery(quest: quest, questImage: questImage)
    case .questSettingsPresentationIsRequired(let quest):
      return navigateToQuestSettingsPresentation(quest: quest)
      
    case .questEditIsRequired(let quest):
      return navigateToEditQuest(quest: quest)
    case .questAuthorImagesPresentationIsRequired(let quest):
      return navigateToQuestAuthorImagesPresentation(quest: quest)
    case .questAuthorImagesPhotoLibraryIsRequired(let quest):
      return navigateToAuthorImagesPhotoLibrary(quest: quest)
    case .questAuthorImagesCameraIsRequired(let quest):
      return navigateToAuthorImagesCamera(quest: quest)
      
    case .questPreviewIsRequired(let quest):
      return navigateToQuestPreview(quest: quest)
    case .questPreviewImagePresentationIsRequired(let quest):
      return navigateToQuestPreviewImagePresentation(quest: quest)
    case .questPreviewImagePhotoLibraryIsRequired(let quest):
      return navigateToQuestPreviewImagePhotoLibrary(quest: quest)
    case .questPreviewImageCameraIsRequired(let quest):
      return navigateToQuestPreviewImageCamera(quest: quest)
      
    case .questProcessingIsCompleted:
      return navigateBack(tabBarIsHidden: false)
    case .dismiss:
      return dismiss()
    case .dismissAndNavigateBack:
      return dismissAndNavigateBack(tabBarIsHidden: true)
    case .navigateBack:
      return navigateBack(tabBarIsHidden: false)
    case .questPreviewProcessingIsCompleted:
      return navigateBack(tabBarIsHidden: true)
   
    default:
      return .none
    }
  }

  private func navigateToMarketplace() -> FlowContributors {
    let viewController = MarketplaceViewController()
    let viewModel = MarketplaceViewModel(services: services)
    viewController.viewModel = viewModel
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToSearch() -> FlowContributors {
    let viewController = SearchViewController()
    let viewModel = SearchViewModel(services: services)
    
    let searchQuestsViewController = SearchQuestsViewController()
    let searchQuestsViewModel = SearchQuestsViewModel(services: services)
    
    let searchUsersViewController = SearchUsersViewController()
    let searchUsersViewModel = SearchUsersViewModel(services: services)
    
    searchQuestsViewController.viewModel = searchQuestsViewModel
    searchUsersViewController.viewModel = searchUsersViewModel
    
    viewController.viewControllers = [searchQuestsViewController, searchUsersViewController]
    viewController.viewModel = viewModel
    
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: CompositeStepper(steppers: [viewModel, searchQuestsViewModel, searchUsersViewModel])
    ))
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

  private func navigateToOpenQuest(quest: Quest) -> FlowContributors {
    let viewController = QuestViewController()
    let viewModel = QuestViewModel(services: services, quest: quest)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToEditQuest(quest: Quest) -> FlowContributors {
    let viewController = QuestEditViewController()
    let viewModel = QuestEditViewModel(services: services, quest: quest)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToQuestPreview(quest: Quest) -> FlowContributors {
    let viewController = QuestEditPreviewViewController()
    let viewModel = QuestEditPreviewViewModel(services: services, quest: quest)
    viewController.viewModel = viewModel
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToQuestGallery(quest: Quest, questImage: QuestImage) -> FlowContributors {
    let viewController = QuestGalleryViewController()
    let viewModel = QuestGalleryViewModel(services: services, quest: quest, questImage: questImage)
    viewController.viewModel = viewModel
    viewController.modalPresentationStyle = .fullScreen
    rootViewController.tabBarController?.tabBar.isHidden = true
    rootViewController.present(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToQuestSettingsPresentation(quest: Quest) -> FlowContributors {
    let viewController = QuestSettingsPresentationViewController()
    let viewModel = QuestSettingsPresentationViewModel(services: services, quest: quest)
    viewController.viewModel = viewModel

    if let sheet = viewController.sheetPresentationController {
      let multiplier = 0.25
      let fraction = UISheetPresentationController.Detent.custom { context in
        UIScreen.main.bounds.height * multiplier
      }
      sheet.prefersGrabberVisible = true
      sheet.detents = [fraction, .medium()]
    }
    
    rootViewController.present(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToQuestAuthorImagesPresentation(quest: Quest) -> FlowContributors {
    let viewController = QuestImagePresentationViewController()
    let viewModel = QuestImagePresentationViewModel(services: services, quest: quest, isQuestPreviewImage: false)
    viewController.viewModel = viewModel
    
    if let sheet = viewController.sheetPresentationController {
      let multiplier = 0.25
      let fraction = UISheetPresentationController.Detent.custom { context in
        UIScreen.main.bounds.height * multiplier
      }
      sheet.detents = [fraction, .medium()]
      sheet.prefersGrabberVisible = true
    }
   
    rootViewController.present(viewController, animated: true)

    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToQuestPreviewImagePresentation(quest: Quest) -> FlowContributors {
    let viewController = QuestImagePresentationViewController()
    let viewModel = QuestImagePresentationViewModel(services: services, quest: quest, isQuestPreviewImage: true)
    viewController.viewModel = viewModel
    
    if let sheet = viewController.sheetPresentationController {
      let multiplier = 0.25
      let fraction = UISheetPresentationController.Detent.custom { context in
        UIScreen.main.bounds.height * multiplier
      }
      sheet.detents = [fraction, .medium()]
      sheet.prefersGrabberVisible = true
    }
   
    rootViewController.present(viewController, animated: true)

    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToAuthorImagesPhotoLibrary(quest: Quest) -> FlowContributors {
    var options = PickerOptionsInfo()
    options.selectLimit = 10
    options.selectionTapAction = .openEditor
    options.saveEditedAsset = false
    options.editorOptions = [.photo]
    options.editorPhotoOptions.toolOptions = [.crop]
    options.editorPhotoOptions.cropOptions = [.custom(w: 5, h: 10)]

    let viewController = PhotoLibraryViewController(options: options)
    let viewModel = PhotoLibraryViewModel(services: services, imagePickerMode: .questAuthorImages(quest: quest))
    viewController.viewModel = viewModel
    viewController.modalPresentationStyle = .fullScreen
    
    rootViewController.dismiss(animated: true)
    rootViewController.present(viewController, animated: true)
    
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToAuthorImagesCamera(quest: Quest) -> FlowContributors {
    var options = CaptureOptionsInfo()
    options.mediaOptions = [.photo]
    options.photoAspectRatio = .ratio1x1
    options.flashMode = .off
    options.preferredPresets = CapturePreset.createPresets(enableHighResolution: true, enableHighFrameRate: true)
    
    let viewController = CameraPickerController(options: options)
    let viewModel = CameraPickerViewModel(services: services, imagePickerMode: .questPreviewImage(quest: quest))
    viewController.viewModel = viewModel
    viewController.modalPresentationStyle = .fullScreen
    
    rootViewController.dismiss(animated: true)
    rootViewController.present(viewController, animated: true)
    
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToQuestPreviewImagePhotoLibrary(quest: Quest) -> FlowContributors {
    var options = PickerOptionsInfo()
    options.selectLimit = 1
    options.selectionTapAction = .openEditor
    options.saveEditedAsset = false
    options.editorOptions = [.photo]
    options.editorPhotoOptions.toolOptions = [.crop]
    options.editorPhotoOptions.cropOptions = [.custom(w: 5, h: 10)]

    let viewController = PhotoLibraryViewController(options: options)
    let viewModel = PhotoLibraryViewModel(services: services, imagePickerMode: .questPreviewImage(quest: quest))
    viewController.viewModel = viewModel
    viewController.modalPresentationStyle = .fullScreen
    
    rootViewController.dismiss(animated: true)
    rootViewController.present(viewController, animated: true)
    
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToQuestPreviewImageCamera(quest: Quest) -> FlowContributors {
    var options = CaptureOptionsInfo()
    options.mediaOptions = [.photo]
    options.photoAspectRatio = .ratio1x1
    options.flashMode = .off
    options.preferredPresets = CapturePreset.createPresets(enableHighResolution: true, enableHighFrameRate: true)
    
    let viewController = CameraPickerController(options: options)
    let viewModel = CameraPickerViewModel(services: services, imagePickerMode: .questPreviewImage(quest: quest))
    viewController.viewModel = viewModel
    viewController.modalPresentationStyle = .fullScreen
    
    rootViewController.dismiss(animated: true)
    rootViewController.present(viewController, animated: true)
    
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  
  private func dismissAndNavigateBack(tabBarIsHidden: Bool) -> FlowContributors {
    rootViewController.tabBarController?.tabBar.isHidden = tabBarIsHidden
    rootViewController.dismiss(animated: true)
    return .one(flowContributor: .forwardToCurrentFlow(withStep: AppStep.navigateBack))
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
}
