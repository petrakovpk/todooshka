//
//  SupportViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 03.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SupportViewController: TDViewController {
  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - MVVM
  public var viewModel: SupportViewModel!

  // MARK: - UI Elemenets
  private let emailLabel: UILabel = {
    let label = UILabel()
    label.text = "Введите email:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()

  private let emailTextField: TDAuthTextField = {
    let textField = TDAuthTextField(type: .email)
    return textField
  }()

  private let questionLabel: UILabel = {
    let label = UILabel()
    label.text = "Напишите свой вопрос:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()

  private let questionTextView: UITextView = {
    let textView = UITextView()
    textView.borderWidth = 1.0
    textView.cornerRadius = 13
    textView.borderColor = Style.TextFields.AuthTextField.Border
    textView.backgroundColor = Style.TextFields.AuthTextField.Background
    return textView
  }()

  private let sendButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 13
    button.setTitle("Отправить запрос", for: .normal)
    return button
  }()

  private let resultLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.textAlignment = .center
    label.text = "Ваш запрос отправлен! Ответ придет по электронной почте."
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.isHidden = true
    return label
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    // adding
    view.addSubviews([
      emailLabel,
      emailTextField,
      questionLabel,
      questionTextView,
      sendButton,
      resultLabel
    ])

    //  header
    titleLabel.text = "Написать в поддержку"

    // emailLabel
    emailLabel.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16)

    // textField
    emailTextField.becomeFirstResponder()
    emailTextField.anchor(top: emailLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16, heightConstant: 54)

    // questionLabel
    questionLabel.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16)

    // questionTextView
    questionTextView.anchor(top: questionLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16, heightConstant: 150)

    // sendButton
    sendButton.anchor(top: questionTextView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 50)

    // resultLabel
    resultLabel.anchor(top: sendButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 32, leftConstant: 16, rightConstant: 16)

    // keyboard
    hideKeyboardWhenTappedAround()
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = SupportViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      emailTextFieldText: emailTextField.rx.text.orEmpty.asDriver(),
      questionTextViewText: questionTextView.rx.text.orEmpty.asDriver(),
      sendButtonClickTrigger: sendButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.navigateBack.drive(),
      outputs.sendButtonIsEnabled.drive(sendButtonIsEnabledBinder),
      outputs.sendQuestion.drive(sendQuestionBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }

  var sendButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in
      vc.sendButton.backgroundColor = isEnabled ? Style.Buttons.NextButton.EnabledBackground : Style.Buttons.NextButton.DisabledBackground
      vc.sendButton.setTitleColor(isEnabled ? .white : Style.App.text?.withAlphaComponent(0.12), for: .normal)
      vc.sendButton.isEnabled = isEnabled
    })
  }

  var sendQuestionBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.sendButton.isHidden = true
      vc.resultLabel.isHidden = false
      vc.emailTextField.isEnabled = false
      vc.questionTextView.isPagingEnabled = false
    })
  }
}
