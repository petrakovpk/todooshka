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
  
  //MARK: - Bind
  func bindViewModel() {

    let input = TabBarViewModel.Input(
      createTaskButtonClickTrigger: customTabBar.addTaskButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.createTask.drive(),
      outputs.createActions.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
    
   
  }
}
