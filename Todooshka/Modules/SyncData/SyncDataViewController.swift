//
//  SyncDataViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 15.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SyncDataViewController: TDViewController {
  // MARK: - MVVM
  var viewModel: SyncDataViewModel!

  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - UI Elemenets
  private let taskDeviceLabel: UILabel = {
    let label = UILabel()
    label.text = "Задач на устройстве"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    return label
  }()

  private let taskDeviceCountLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    label.textAlignment = .center
    return label
  }()

  private let taskFirebaseLabel: UILabel = {
    let label = UILabel()
    label.text = "Задач в облаке"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    return label
  }()

  private let taskFirebaseCountLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    label.textAlignment = .center
    return label
  }()

  private let taskSyncButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 13
    button.setTitle("Загрузить задачи из облака", for: .normal)
    return button
  }()

  private let kindsOfTaskDeviceLabel: UILabel = {
    let label = UILabel()
    label.text = "Типов задач на устройстве"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    return label
  }()

  private let kindsOfTaskDeviceCountLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    label.textAlignment = .center
    return label
  }()

  private let kindsOfTaskFirebaseLabel: UILabel = {
    let label = UILabel()
    label.text = "Типов задач в облаке"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    return label
  }()

  private let kindsOfTaskFirebaseCountLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    label.textAlignment = .center
    return label
  }()

  private let kindsOfTaskSyncButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 13
    button.setTitle("Загрузить типы задач из облака", for: .normal)
    return button
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    // Init
    let stackView1 = UIStackView(arrangedSubviews: [taskDeviceLabel, taskFirebaseLabel], axis: .horizontal)
    stackView1.distribution = .fillEqually

    let stackView2 = UIStackView(arrangedSubviews: [taskDeviceCountLabel, taskFirebaseCountLabel], axis: .horizontal)
    stackView2.distribution = .fillEqually

    let stackView3 = UIStackView(arrangedSubviews: [kindsOfTaskDeviceLabel, kindsOfTaskFirebaseLabel], axis: .horizontal)
    stackView3.distribution = .fillEqually

    let stackView4 = UIStackView(arrangedSubviews: [kindsOfTaskDeviceCountLabel, kindsOfTaskFirebaseCountLabel], axis: .horizontal)
    stackView4.distribution = .fillEqually

    //  header
    backButton.isHidden = false
    titleLabel.text = "Синхронизируем данные"

    // adding
    view.addSubviews([
      stackView1,
      stackView2,
      taskSyncButton,
      stackView3,
      stackView4,
      kindsOfTaskSyncButton
    ])

    // stackView1
    stackView1.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 30)

    // stackView2
    stackView2.anchor(top: stackView1.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 30)

    // syncButton
    taskSyncButton.anchor(top: stackView2.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 50)

    // stackView1
    stackView3.anchor(top: taskSyncButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 30)

    // stackView2
    stackView4.anchor(top: stackView3.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 30)

    // syncButton
    kindsOfTaskSyncButton.anchor(top: stackView4.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 50)
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = SyncDataViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      kindsOfTaskSyncButtonClickTrigger: kindsOfTaskSyncButton.rx.tap.asDriver(),
      taskSyncButtonClickTrigger: taskSyncButton.rx.tap.asDriver()
    )

//    let outputs = viewModel.transform(input: input)

//    [
//      outputs.kindsOfTaskDeviceCountLabel.drive(kindsOfTaskDeviceCountLabel.rx.text),
//      outputs.kindsOfTaskFirebaseCountLabel.drive(kindsOfTaskFirebaseCountLabel.rx.text),
//      outputs.kindsOfTaskSync.drive(),
//      outputs.kindsOfTaskSyncButtonIsEnabled.drive(kindsOfTaskSyncButtonIsEnabledBinder),
//      outputs.navigateBack.drive(),
//      outputs.taskDeviceCountLabel.drive(taskDeviceCountLabel.rx.text),
//      outputs.taskFirebaseCountLabel.drive(taskFirebaseCountLabel.rx.text),
//      outputs.taskSync.drive(),
//      outputs.taskSyncButtonIsEnabled.drive(taskSyncButtonIsEnabledBinder)
//    ]
//      .forEach({ $0.disposed(by: disposeBag) })
  }

  var kindsOfTaskSyncButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in
      vc.kindsOfTaskSyncButton.backgroundColor = isEnabled ? Style.Buttons.NextButton.EnabledBackground : Style.Buttons.NextButton.DisabledBackground
      vc.kindsOfTaskSyncButton.setTitleColor(isEnabled ? .white : Style.App.text?.withAlphaComponent(0.12), for: .normal)
      vc.kindsOfTaskSyncButton.isEnabled = isEnabled
    })
  }

  var taskSyncButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in
      vc.taskSyncButton.backgroundColor = isEnabled ? Style.Buttons.NextButton.EnabledBackground : Style.Buttons.NextButton.DisabledBackground
      vc.taskSyncButton.setTitleColor(isEnabled ? .white : Style.App.text?.withAlphaComponent(0.12), for: .normal)
      vc.taskSyncButton.isEnabled = isEnabled
    })
  }
}
