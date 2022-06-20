//
//  DiamondViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 20.06.2022.
//

import UIKit
import RxSwift
import RxCocoa

class DiamondViewController: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - MVVM
  public var viewModel: DiamondViewModel!
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  // MARK: - Configure UI
  func configureUI() {
    titleLabel.text = "Бриллианты"
  }
  
  // MARK: - Bind To
  func bindViewModel() {
    
    let input = DiamondViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.backButtonClickHandler.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
}

