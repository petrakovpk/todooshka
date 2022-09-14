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
    let spacer = UIView()
    textField.borderWidth = 1.0
    textField.borderColor = Palette.DualColors.HawkesBlue_Haiti_7_9_30
    textField.backgroundColor = Palette.DualColors.TitanWhite_224_226_255_
    textField.cornerRadius = 13
    textField.leftView = spacer
    textField.leftViewMode = .always
    textField.placeholder = "Введите имя"
    textField.returnKeyType = .done
    // spacer
    spacer.anchor(widthConstant: 16, heightConstant: 54)
    
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
    titleLabel.text = "Отображаемое имя"
    
    // textField
    textField.becomeFirstResponder()
    textField.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 54)
    
  }
  
  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    
    let input = ChangeNameViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      nameTextFieldEditingDidEndOnExit: textField.rx.controlEvent(.editingDidEndOnExit).asDriver(),
      nameTextFieldText: textField.rx.text.orEmpty.asDriver(),
      saveButtonClickTrigger: saveButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.navigateBack.drive(),
      outputs.name.drive(textField.rx.text),
      outputs.save.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
}
