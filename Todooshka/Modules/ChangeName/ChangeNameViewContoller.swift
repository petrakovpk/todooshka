//
//  ChangeNameViewContoller.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ChangeNameViewContoller: TDViewController {
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - MVVM
  public var viewModel: ChangeNameViewModel!
  
  // MARK: - UI Elemenets
  private let textField: UITextField = {
    let textField = UITextField()
    textField.borderWidth = 1.0
    textField.borderColor = Theme.App.text
    textField.cornerRadius = 5
    return textField
  }()
  
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
    view.addSubview(textField)
    
    //  header
    titleLabel.text = "Сменить имя"
    
    // textField
    textField.becomeFirstResponder()
    textField.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 40)
    
  }
  
  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    
    let input = ChangeNameViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.navigateBack.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
}

