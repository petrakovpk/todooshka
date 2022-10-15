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
  
  //MARK: - Properties
  let customTabBar = TabBar()
  let disposeBag = DisposeBag()
  var viewModel: TabBarViewModel!
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setValue(customTabBar, forKey: "tabBar")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  //MARK: - Bind
  func bindViewModel() {

    let input = TabBarViewModel.Input(
      createTaskButtonClickTrigger: customTabBar.addTaskButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)
    
    [
      outputs.createTask.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    viewModel.selectedItem(item: item)
  }
}
