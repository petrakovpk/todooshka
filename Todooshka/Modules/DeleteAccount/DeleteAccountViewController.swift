//
//  DeleteAccountViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 03.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DeleteAccountViewController: TDViewController {
  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: DeleteAccountViewModel!

  // MARK: - UI Elemenets
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.textAlignment = .center
    textView.isEditable = false
    textView.isSelectable = false
    textView.cornerRadius = 13
    textView.backgroundColor = Style.TextFields.AuthTextField.Background
    textView.centerVerticalText()
    return textView
  }()

  private let errorLabel: UILabel = {
    let label = UILabel()
    label.textColor = .red
    label.font = UIFont.systemFont(ofSize: 14, weight: .thin)
    label.textAlignment = .center
    return label
  }()

  private let successLabel: UILabel = {
    let label = UILabel()
    label.textColor = Palette.SingleColors.Jevel
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    // label.text = "Аккаунт удален!"
    label.isHidden = false
    return label
  }()

  private let removeAccountButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 13
    button.setTitle("Удалить аккаунт", for: .normal)
    button.borderWidth = 1.0
    button.borderColor = .red
    button.setTitleColor(.red, for: .normal)
    return button
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  // MARK: - Configure UI
  func configureUI() {
    backButton.isHidden = false
    
    // adding
    view.addSubviews([
      descriptionTextView,
      successLabel,
      errorLabel,
      removeAccountButton
    ])

    //  header
    titleLabel.text = "Удалить аккаунт"

    // descriptionTextView
    // swiftlint:disable:next line_length
    descriptionTextView.text = "Удаление аккаунта приведет к\n\nПОЛНОМУ СТИРАНИЮ ВСЕХ ДАННЫХ.\n\nВы НИКОГДА не сможете их восстановить.\n\nДанная кнопка появилась из-за требований Apple - типа что бы люди могли стереть все свои информационные следы в интернете."
    // swiftlint:disable:previous line_length
    descriptionTextView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 32,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 130
    )

    // successLabel
    successLabel.anchor(
      top: descriptionTextView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 54
    )

    // errorLabel
    errorLabel.anchor(
      top: successLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 54
    )

    // removeAccountButton
    removeAccountButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = DeleteAccountViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      deleteAccountClickTrigger: removeAccountButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.navigateBack.drive(),
      outputs.errorText.drive(errorLabel.rx.text),
      outputs.deleteAccountButtonIsEnaled.drive(deleteBbuttonIsEnaledBinder),
      outputs.sucessText.drive(successLabel.rx.text)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }

  var deleteBbuttonIsEnaledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in
      vc.removeAccountButton.isEnabled = isEnabled
    })
  }

  var sendQuestionBinder: Binder<Void> {
    return Binder(self, binding: { _, _ in
    })
  }
}
