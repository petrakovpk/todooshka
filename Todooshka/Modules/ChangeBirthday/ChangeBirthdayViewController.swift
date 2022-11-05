//
//  ChangeBirthdayViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ChangeBirthdayViewController: TDViewController {

  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: ChangeBirthdayViewModel!

  // MARK: - UI Elemenets
  private let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
    return label
  }()

  private let picker: UIDatePicker = {
    let picker = UIDatePicker()
    picker.datePickerMode = .date
    picker.preferredDatePickerStyle = .wheels
    picker.locale = Locale(identifier: "ru_RU")
    return picker
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
    view.addSubviews([
      label,
      picker
    ])

    //  header
    titleLabel.text = "Дата рождения"

    // label
    label.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 32,
      leftConstant: 16,
      rightConstant: 16
    )

    // picker
    picker.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {

    let input = ChangeBirthdayViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      datePicker: picker.rx.value.asDriver(),
      saveButtonClickTrigger: saveButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.dateText.drive(label.rx.text),
      outputs.datePickerValue.drive(picker.rx.date),
      outputs.navigateBack.drive(),
      outputs.save.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
}
