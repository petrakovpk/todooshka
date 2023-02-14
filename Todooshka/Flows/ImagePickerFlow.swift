//
//  YPImagePickerFlow.swift
//  DragoDo
//
//  Created by Pavel Petakov on 02.02.2023.
//


import RxFlow
import RxSwift
import RxCocoa
import UIKit
import YPImagePicker

class ImagePickerFlow: Flow {
  var root: Presentable {
     rootViewController
  }

  private let rootViewController = ImagePickerController()
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
    case .addPhotoIsRequired(let task):
      return navigateToAddPhoto(task: task)
    case .dismiss:
      return dismiss()
    default:
      return .none
    }
  }

  private func lol() -> FlowContributors {
    return .none
  }
  
  private func navigateToAddPhoto(task: Task) -> FlowContributors {
    let viewModel = ImagePickerViewModel(services: services, task: task)
    rootViewController.viewModel = viewModel
    rootViewController.delegate = rootViewController
    return .one(flowContributor: .contribute(withNextPresentable: rootViewController, withNextStepper: viewModel))
  }
  
  private func dismiss() -> FlowContributors {
    rootViewController.dismiss(animated: true)
    return .none
  }
  
}

