//
//  AlertFlow.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 12.09.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class AlertFlow: Flow {

  // MARK: - Properties
  var root: Presentable {
    return self.rootViewController
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

    case .dismiss:
      return dismiss()

    default:
      return .none
    }
  }

  private func dismiss() -> FlowContributors {
    rootViewController.dismiss(animated: true)
    return .none
  }

}
