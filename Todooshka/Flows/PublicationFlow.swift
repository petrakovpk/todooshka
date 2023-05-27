//
//  PublicationFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.05.2023.
//

import AnyImageKit
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class PublicationFlow: Flow {
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
      return navigateToAuth()
      
    case .publicationIsRequired(let publication):
      return navigateToPublication(publication: publication)
    case .publicationEditIsRequired(let publication, let publicationImage):
      return navigateToEditPublication(publication: publication, publicationImage: publicationImage)
   
    case .publicationCameraIsRequired(let publication):
      return navigateToCamera(publication: publication)
    case .publicationPhotoLibraryIsRequired(let publication):
      return navigateToImageLibrary(publication: publication)
//    case .publicationPublicKindIsRequired(let publication):
//      return navigateToPublicKindIsRequired(publication: publication)
//      
    case .navigateBack:
      return navigateBack()
    case .publicationProcesingIsCompleted,
        .publicationEditProcesingIsCompleted,
        .dismiss:
      return dismiss()
    
    default:
      return .none
    }
  }
  
  private func navigateToPublication(publication: Publication) -> FlowContributors {
    let viewController = PublicationViewController()
    let viewModel = PublicationViewModel(services: services, publication: publication, publicationMode: .publication)
    viewController.viewModel = viewModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.setViewControllers([viewController], animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToAuth() -> FlowContributors {
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
  
//  private func navigateToPublicKindIsRequired(publication: Publication) -> FlowContributors {
//    let viewController = PublicationPublicKindViewController()
//    let viewModel = PublicationPublicKindViewModel(services: services, publication: publication)
//    viewController.viewModel = viewModel
//
//    if let sheet = viewController.sheetPresentationController {
//      let multiplier = 0.5
//      let fraction = UISheetPresentationController.Detent.custom { context in
//        UIScreen.main.bounds.height * multiplier
//      }
//      sheet.detents = [fraction]
//    }
//
//    rootViewController.tabBarController?.tabBar.isHidden = false
//    rootViewController.present(viewController, animated: true)
//
//    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
//  }
  
  
  private func navigateToEditPublication(publication: Publication, publicationImage: PublicationImage?) -> FlowContributors {
    let viewController = PublicationEditViewController()
    let viewModel = PublicationEditViewModel(services: services, publication: publication, publicationImage: publicationImage)
    viewController.viewModel = viewModel
    rootViewController.navigationBar.isHidden = true
    rootViewController.dismiss(animated: true)
    rootViewController.setViewControllers([viewController], animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  private func navigateToCamera(publication: Publication) -> FlowContributors {
    var options = CaptureOptionsInfo()
    options.mediaOptions = [.photo]
    options.photoAspectRatio = .ratio1x1
    options.flashMode = .off
    options.preferredPresets = CapturePreset.createPresets(enableHighResolution: true, enableHighFrameRate: true)
    
    let viewController = CameraPickerController(options: options)
    let viewModel = CameraPickerViewModel(services: services, imagePickerMode: .publication(publication: publication))
    viewController.viewModel = viewModel
    viewController.modalPresentationStyle = .fullScreen
    
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

  private func navigateBack() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }

  private func dismiss() -> FlowContributors {
    rootViewController.dismiss(animated: true)
    return .none
  }
}

