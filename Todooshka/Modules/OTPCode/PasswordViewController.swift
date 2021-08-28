//
//  PasswordViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

class PasswordViewController: UIViewController {
    
    //MARK: - Properties
    var viewModel: PasswordViewModel!
    let disposeBag = DisposeBag()
    
    //MARK: - UI Elements
    
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Todooshka"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let welcomeTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textAlignment = .center
        return textView
    }()
    
    private let passwordTextField = TDAuthTextField(customPlaceholder: "Password")
    
    private let repeatPasswordTextField = TDAuthTextField(customPlaceholder: "Repeat password")
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: TDStyle.Colors.invertedBackgroundColor ]
        let boldAtts: [NSAttributedString.Key: Any] = [.foregroundColor: TDStyle.Colors.invertedBackgroundColor, .font: UIFont.boldSystemFont(ofSize: 15) ]
        
        let attributedTitle = NSMutableAttributedString(string: "Забыли пароль? ", attributes: atts)
        attributedTitle.append(NSAttributedString(string: "Восстановить", attributes: boldAtts))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
                
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textAlignment = .left
        return label
    }()
    
    private let rightBarButtonACtion = UIBarButtonItem(title: "Next", style: .plain, target: self, action: nil)
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        configureUI()
        setViewColor()
        setTextColor()
    }
    
    //MARK: - Configure UI
    func configureUI() {
        navigationItem.rightBarButtonItem = rightBarButtonACtion
        
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold) ], for: .normal)
        
        view.addSubview(appNameLabel)
        appNameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 75, leftConstant: 16,  rightConstant: 16)
        
        view.addSubview(welcomeTextView)
        welcomeTextView.anchor(top: appNameLabel.bottomAnchor, left: view.leftAnchor,  right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16,  heightConstant: 56)
        
        passwordTextField.becomeFirstResponder()
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
        passwordTextField.anchor(top: appNameLabel.bottomAnchor, left: view.leftAnchor,  right: view.rightAnchor, topConstant: 64, leftConstant: 16, rightConstant: 16,  heightConstant: 50)
        
        
        repeatPasswordTextField.isSecureTextEntry = true
        view.addSubview(repeatPasswordTextField)
        repeatPasswordTextField.anchor(top: passwordTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16,  rightConstant: 16,  heightConstant: 50)
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.anchorCenterXToSuperview()
        forgotPasswordButton.anchor(top: passwordTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 24, leftConstant: 16, rightConstant: 16)
    }
    
    func setNewUserMode() {
        forgotPasswordButton.isHidden = true
        repeatPasswordTextField.isHidden = false
        passwordTextField.returnKeyType = .next
        repeatPasswordTextField.returnKeyType = .done
        welcomeTextView.text = "Добро пожаловать!\nДля продолжения регистрации введите пароль."
        view.addSubview(errorLabel)
        errorLabel.anchor(top: repeatPasswordTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 0, rightConstant: 16)
    }
    
    func setExistUserMode() {
        forgotPasswordButton.isHidden = false
        repeatPasswordTextField.isHidden = true
        passwordTextField.returnKeyType = .done
        welcomeTextView.text = "Снова привет!\nДля входа введите пароль."
        view.addSubview(errorLabel)
        errorLabel.anchor(top: passwordTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, rightConstant: 16)
    }
    
    func setLoadingMode(isLoading:Bool) {
        passwordTextField.isEnabled = !isLoading
        repeatPasswordTextField.isEnabled = !isLoading
        navigationItem.rightBarButtonItem?.isEnabled = !isLoading
    }
    
    //MARK: - Bind to ViewModel
    
    func bindTo(with viewModel: PasswordViewModel) {
        
        self.viewModel = viewModel
        
        // inputs (Properties to ViewModel)
        passwordTextField.rx.text.orEmpty.bind(to: viewModel.passwordTextInput).disposed(by: disposeBag)
        repeatPasswordTextField.rx.text.orEmpty.bind(to: viewModel.repeatPasswordTextInput).disposed(by: disposeBag)
        
        // inputs (Actions to ViewModel)
        rightBarButtonACtion.rx.tap.bind { viewModel.logIn() }.disposed(by: disposeBag)
        
        passwordTextField.rx.controlEvent(.editingDidEndOnExit).subscribe { [weak self] _ in
            switch viewModel.isNewUser.value {
            case true:
                self?.repeatPasswordTextField.becomeFirstResponder()
            case false:
                viewModel.logIn()
            }
        }.disposed(by: disposeBag)
        
        repeatPasswordTextField.rx.controlEvent(.editingDidEndOnExit).subscribe { _ in
            viewModel.logIn()
        }.disposed(by: disposeBag)
        
        // outputs (Properties from ViewModel)
        viewModel.errorTextOutput.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.isNewUser.bind { [weak self] isNewUser in
            isNewUser ? self?.setNewUserMode() : self?.setExistUserMode()
        }.disposed(by: disposeBag)
        
        viewModel.isLoadingOutput.bind { [weak self] isLoading in
            self?.setLoadingMode(isLoading: isLoading)
        }.disposed(by: disposeBag)
    }
}

//MARK: - TDConfigureColorProtocol
extension PasswordViewController: TDConfigureColorProtocol {
    func setViewColor() {
        view.backgroundColor = TDStyle.Colors.backgroundColor
    }
    
    func setTextColor() {
        errorLabel.textColor = UIColor.systemRed
    }
}
