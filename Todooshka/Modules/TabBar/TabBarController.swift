//
//  TabBarController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

class TabBarController: UITabBarController, UITabBarControllerDelegate {
  public var viewModel: TabBarViewModel!
  
  private let customTabBar = TabBar()
  private let disposeBag = DisposeBag()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  func configureUI() {
    setValue(customTabBar, forKey: "tabBar")
    customTabBar.configureUI()
  }
  
  // MARK: - Bind
  func bindViewModel() {
    let input = TabBarViewModel.Input(
      tabBarAddButtonClickTrigger: customTabBar.addTaskButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.showAddTabBarPresentation.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
}
