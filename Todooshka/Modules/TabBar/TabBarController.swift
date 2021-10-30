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
    configureUI()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    setValue(customTabBar, forKey: "tabBar")
  }
  
  //MARK: - Bind
  func bindViewModel() {
    
    let input = TabBarViewModel.Input(
      createTaskButtonClickTrigger: customTabBar.addTaskButton.rx.tap.asDriver() 
    )
    
    let output = viewModel.transform(input: input)
    output.createTask.drive().disposed(by: disposeBag)
    
  //  customTabBar.addTaskButton.rx.tapGesture().bind{_ in viewModel.handleAddTaskClick()}.disposed(by: disposeBag)
  }
}
