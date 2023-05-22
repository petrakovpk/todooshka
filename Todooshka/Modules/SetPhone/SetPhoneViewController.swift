//
//  SetPhoneViewController.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import Firebase
import RxSwift
import RxCocoa
import RxDataSources
import UIKit

class SetPhoneViewController: TDViewController {
  public var viewModel: SetPhoneViewModel!
  
  private let disposeBag = DisposeBag()
  
  private let phoneNumberTextField = TDAuthTextField(type: .phone)
  private let OTPCodeTextField = TDAuthTextField(type: .otp)
  
  private let phoneLabel: UILabel = {
    let label = UILabel()
    label.text = ""
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()

  private let sendOTPCodeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Отправить код", for: .normal)
    button.cornerRadius = 13
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.lineBreakMode = .byWordWrapping
    button.titleLabel?.textAlignment = .center
    return button
  }()

  private let checkOTPCodeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Подтвердить", for: .normal)
    button.cornerRadius = 13
    button.backgroundColor = Palette.SingleColors.BlueRibbon
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.lineBreakMode = .byWordWrapping
    button.titleLabel?.textAlignment = .center
    return button
  }()

  private let errorTextView: UITextView = {
    let textView = UITextView()
    textView.textAlignment = .center
    textView.isEditable = false
    textView.isSelectable = false
    textView.font = UIFont.systemFont(ofSize: 12, weight: .light)
    textView.textColor = UIColor(red: 0.937, green: 0.408, blue: 0.322, alpha: 1)
    textView.backgroundColor = .clear
    return textView
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    backButton.isHidden = false
    titleLabel.text = "Телефонные номера"
    
    // adding
    view.addSubviews([
      phoneLabel,
      phoneNumberTextField,
      OTPCodeTextField,
      sendOTPCodeButton,
      checkOTPCodeButton,
      errorTextView
    ])

    // signedPhoneNumberLabel
    phoneLabel.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16
    )

    // sendCodeButton
    sendOTPCodeButton.anchor(
      top: phoneLabel.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      rightConstant: 16,
      widthConstant: 125,
      heightConstant: 50
    )

    // phoneNumberTextField
    phoneNumberTextField.becomeFirstResponder()
    phoneNumberTextField.anchor(
      top: phoneLabel.bottomAnchor,
      left: view.leftAnchor,
      right: sendOTPCodeButton.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )

    // sendCodeButton
    checkOTPCodeButton.anchor(
      top: phoneNumberTextField.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      rightConstant: 16,
      widthConstant: 125,
      heightConstant: 50
    )

    // OTPCodeTextField
    OTPCodeTextField.anchor(
      top: phoneNumberTextField.bottomAnchor,
      left: view.leftAnchor,
      right: checkOTPCodeButton.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )

    // errorTextView
    errorTextView.anchor(
      top: OTPCodeTextField.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )
  }

  // MARK: - Bind ViewModel
  func bindViewModel() {
    let input = SetPhoneViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      checkOTPCodeButtonClickTrigger: checkOTPCodeButton.rx.tap.asDriver(),
      phoneTextFieldText: phoneNumberTextField.rx.text.orEmpty.asDriver(),
      saveButtonClickTrigger: headerSaveButton.rx.tap.asDriver(),
      sendOTPCodeButtonClickTrigger: sendOTPCodeButton.rx.tap.asDriver(),
      OTPCodeTextFieldText: OTPCodeTextField.rx.text.orEmpty.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.checkOTPCodeButtonIsEnabled.drive(checkOTPCodeButtonIsEnabledBinder),
      outputs.correctOTPCode.drive(OTPCodeTextField.rx.text),
      outputs.correctPhoneNumber.drive(phoneNumberTextField.rx.text),
      outputs.errorText.drive(errorTextView.rx.text),
      outputs.isPhoneNotSet.drive(isPhoneNotSetBinder),
      outputs.sendCodeButtonIsEnabled.drive(sendCodeButtonIsEnabledBinder),
      outputs.navigateBack.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }

  var isPhoneNotSetBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isPhoneNotSet in
      if isPhoneNotSet {
        vc.phoneLabel.text = "Введите номер:"
        vc.phoneNumberTextField.isEnabled = true
        vc.OTPCodeTextField.isHidden = false
        vc.checkOTPCodeButton.isHidden = false
      } else {
        vc.phoneLabel.text = "У вас уже установлен номер:"
        vc.phoneNumberTextField.isEnabled = false
        vc.OTPCodeTextField.isHidden = true
        vc.checkOTPCodeButton.isHidden = true
      }
    })
  }

  var successLinkBinder: Binder<AuthDataResult> {
    return Binder(self, binding: { vc, _ in
      vc.phoneNumberTextField.clear()
      vc.OTPCodeTextField.clear()
    })
  }

  var checkOTPCodeButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in
      vc.checkOTPCodeButton.backgroundColor = isEnabled ? Style.Buttons.NextButton.EnabledBackground : Style.Buttons.NextButton.DisabledBackground
      vc.checkOTPCodeButton.setTitleColor(isEnabled ? .white : Style.App.text?.withAlphaComponent(0.12), for: .normal)
      vc.checkOTPCodeButton.isEnabled = isEnabled
    })
  }

  var sendCodeButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in
      vc.sendOTPCodeButton.backgroundColor = isEnabled ? Style.Buttons.NextButton.EnabledBackground : Style.Buttons.NextButton.DisabledBackground
      vc.sendOTPCodeButton.setTitleColor(isEnabled ? .white : Style.App.text?.withAlphaComponent(0.12), for: .normal)
      vc.sendOTPCodeButton.isEnabled = isEnabled
    })
  }
}
