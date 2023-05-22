//
//  AddSheetViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.04.2023.
//

import UIKit
import RxCocoa
import RxSwift

class AddPresentationViewController: UIViewController {
  public var viewModel: AddPresentationViewModel!
  
  private let disposeBag = DisposeBag()
  
  private let divider: UIView = {
    let view = UIView()
    view.backgroundColor = Style.Views.CalendarDivider.Background
    return view
  }()
  
  private let createPublicationButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Публикация",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)]
    )
    let button = UIButton(type: .system)
    button.backgroundColor = Palette.SingleColors.Rose
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let createTaskButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Задача",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)]
    )
    let button = UIButton(type: .system)
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  func configureUI() {
    view.backgroundColor = Style.App.background
    
    view.addSubviews([
      divider,
      createPublicationButton,
      createTaskButton
    ])
    
    divider.anchorCenterXToSuperview()
    divider.anchor(top: view.topAnchor, topConstant: 16, widthConstant: 60, heightConstant: 2)
    
    createPublicationButton.anchorCenterXToSuperview(constant: -1 * UIScreen.main.bounds.width / 4 + 20)
    createPublicationButton.anchorCenterYToSuperview(constant: -20)
    createPublicationButton.anchor(widthConstant: 100, heightConstant: 100)
    createPublicationButton.cornerRadius = 40
    
    createTaskButton.anchorCenterXToSuperview(constant: UIScreen.main.bounds.width / 4 - 20)
    createTaskButton.anchorCenterYToSuperview(constant: -20)
    createTaskButton.anchor(widthConstant: 100, heightConstant: 100)
    createTaskButton.cornerRadius = 40
  }
  
  func bindViewModel() {
    let input = AddPresentationViewModel.Input(
      createPublicationButtonClickTrigger: createPublicationButton.rx.tap.asDriver(),
      createTaskButtonClickTrigger: createTaskButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.createPublication.drive(),
      outputs.createTask.drive()
      
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
}
