//
//  OTPCodeViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

class OTPCodeViewController: UIViewController {

    // MARK: - Properties
    let disposeBag = DisposeBag()

    var viewModel: OTPCodeViewModel!

    // MARK: - UI Components
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Todooshka"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()

    private let otpTextField: UITextField = {
        let placeholderString = NSAttributedString(string: "------", attributes: [NSAttributedString.Key.kern: 6.0])

        let textField = UITextField()
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 5
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.returnKeyType = .next
        textField.font = UIFont.systemFont(ofSize: 20, weight: .light)
        textField.defaultTextAttributes.updateValue(6.0, forKey: NSAttributedString.Key.kern)
        textField.attributedPlaceholder = placeholderString
        textField.becomeFirstResponder()
        return textField
    }()

    private let otpLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите 6-значный код из SMS"
        label.textAlignment = .center
        return label
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textAlignment = .center
        return label
    }()

    let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: nil)

    override func viewDidLoad() {
        configureUI()
     //   setViewColor()
      //  setTextColor()
    }

    func configureUI() {

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold) ], for: .normal)

        view.addSubview(appNameLabel)
        appNameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,    right: view.rightAnchor, topConstant: 75, leftConstant: 16,    rightConstant: 16)

        view.addSubview(otpLabel)
        otpLabel.anchor(top: appNameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16,    rightConstant: 16)

        view.addSubview(otpTextField)
        otpTextField.anchorCenterXToSuperview()
        otpTextField.anchor(top: appNameLabel.bottomAnchor,    topConstant: 64, leftConstant: 16, rightConstant: 16, widthConstant: 150, heightConstant: 50)

        view.addSubview(errorLabel)
        errorLabel.anchor(top: otpTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16,    rightConstant: 16)
    }

    func setLoadingMode(isLoading: Bool) {
        otpTextField.isEnabled = !isLoading
        navigationItem.rightBarButtonItem?.isEnabled = !isLoading
        if !isLoading { otpTextField.becomeFirstResponder() }
    }

    func bindTo(with viewModel: OTPCodeViewModel) {
//        self.viewModel = viewModel
//        
//        // inputs (Properties to ViewModel)
//        otpTextField.rx.text.orEmpty.bind(to: viewModel.OTPCodeTextInput).disposed(by: disposeBag)
//        
//        // inputs (Actions to ViewModel)
//        rightBarButtonItem.rx.tap.bind { viewModel.logIn() }.disposed(by: disposeBag)
//        
//        // outputs (Properties from ViewModel)
//        viewModel.OTPCodeTextOutput.bind(to: otpTextField.rx.text).disposed(by: disposeBag)
//        viewModel.errorTextOutput.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
//        viewModel.isLoadingOutput.bind { [weak self] isLoading in
//            self?.setLoadingMode(isLoading: isLoading)
//        }.disposed(by: disposeBag)
    }
}

// MARK: - TDConfigureColorProtocol
// extension OTPCodeViewController: TDConfigureColorProtocol {
//    func setViewColor() {
//        view.backgroundColor = TDStyle.Colors.backgroundColor
//    }
//    
//    func setTextColor() {
//        errorLabel.textColor = UIColor.systemRed
//    }
// }
