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
  private let deviceLabel: UILabel = {
    let label = UILabel()
    label.text = "Задач на устройстве"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    return label
  }()
  
  private let deviceCountLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    label.textAlignment = .center
    return label
  }()
  
  private let firebaseLabel: UILabel = {
    let label = UILabel()
    label.text = "Задач в облаке"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    return label
  }()
  
  private let firebaseCountLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    label.textAlignment = .center
    return label
  }()
  
  private let syncButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 13
    button.setTitle("Загрузить данные из облака", for: .normal)
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
    let stackView1 = UIStackView(arrangedSubviews: [deviceLabel, firebaseLabel], axis: .horizontal)
    stackView1.distribution = .fillEqually
    
    let stackView2 = UIStackView(arrangedSubviews: [deviceCountLabel, firebaseCountLabel], axis: .horizontal)
    stackView2.distribution = .fillEqually
    
    //  header
    titleLabel.text = "Синхронизируем данные"
    
    // adding
    view.addSubviews([
      stackView1,
      stackView2,
      syncButton
    ])
    
    // stackView1
    stackView1.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 30)

    // stackView2
    stackView2.anchor(top: stackView1.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 30)
    
    // syncButton
    syncButton.anchor(top: stackView2.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 50)

  }
  
  
  // MARK: - Bind ViewModel
  func bindViewModel() {
    
    let input = SyncDataViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      syncButtonClickTrigger: syncButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.deviceCountLabel.drive(deviceCountLabel.rx.text),
      outputs.firebaseCountLabel.drive(firebaseCountLabel.rx.text),
      outputs.navigateBack.drive(),
      outputs.sync.drive(),
      outputs.syncButtonIsEnabled.drive(syncButtonIsEnabledBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  var syncButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { (vc, isEnabled) in
      vc.syncButton.backgroundColor = isEnabled ? Palette.SingleColors.BlueRibbon : Palette.DualColors.Mischka_205_205_223_
      vc.syncButton.setTitleColor(isEnabled ? .white : Theme.App.text?.withAlphaComponent(0.12) , for: .normal)
      vc.syncButton.isEnabled = isEnabled
    })
  }
}

