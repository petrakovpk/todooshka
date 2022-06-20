//
//  FeatherViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 20.06.2022.
//

import UIKit
import RxSwift
import RxCocoa

class FeatherViewController: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - MVVM
  public var viewModel: FeatherViewModel!
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  // MARK: - Configure UI
  func configureUI() {
    titleLabel.text = "Перышко"
  }
  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    
    let input = FeatherViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.backButtonClickHandler.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
}
