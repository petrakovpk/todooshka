//
//  ChangeEmailViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ChangeEmailViewController: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - MVVM
  public var viewModel: ChangeEmailViewModel!
  
  // MARK: - UI Elemenets
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  // MARK: - Configure UI
  func configureUI() {
    // settings
    saveButton.isHidden = false
    
    // adding

    
    //  header
    titleLabel.text = "Сменить имя"
    
    // textField

  }
  
  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    
    let input = ChangeEmailViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.navigateBack.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
}

