//
//  ThemeTaskViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.
//

import RxCocoa
import RxSwift

class ThemeTaskViewController: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: ThemeTaskViewModel!
  
  // MARK: - UI Elements
 
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  func configureUI() {
    backButton.isHidden = false
    hideKeyboardWhenTappedAround()
    
    view.addSubviews([
      
    ])
    
    
  }
  
  func bindViewModel() {
    let input = ThemeDayViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.navigateBack.drive()
      
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
}

