//
//  LoginViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import GoogleSignIn
import Firebase

enum LoginMode {
    case email, password, phone, code
}

class LoginViewModel: Stepper {
    
    //MARK: - Properties
    let steps = PublishRelay<Step>()
    let services: AppServices
    
    let isNewUser: Bool
    
    private let disposeBag = DisposeBag()
    private var verificationId = ""
    
    //MARK: - Input
    let emailTextFieldInput = BehaviorRelay<String>(value: "")
    let passwordTextFieldInput = BehaviorRelay<String>(value: "")
    let repeatPasswordTextFieldInput = BehaviorRelay<String>(value: "")
    let phoneTextFieldInput = BehaviorRelay<String>(value: "")
    let codeTextFieldInput = BehaviorRelay<String>(value: "")
    
    //MARK: - Output
    let loginModeOutput = BehaviorRelay<LoginMode>(value: .email)
    let nextButtonIsEnabledOutput = BehaviorRelay<Bool>(value: false)
    let phoneTextFieldOutput = BehaviorRelay<String>(value: "")
    let errorTextFieldOutput = BehaviorRelay<String>(value: "")
    
    //MARK: - Init
    init(services: AppServices, isNewUser: Bool) {
        self.services = services
        self.isNewUser = isNewUser
        bindInputs()
    }
    
    //MARK: - Bind Inputs
    func bindInputs() {
        
        loginModeOutput.bind{[weak self] _ in
            guard let self = self else { return }
            self.errorTextFieldOutput.accept("")
            self.checkNextButton()
        }.disposed(by: disposeBag)
        
        emailTextFieldInput.bind{[weak self] email in
            guard let self = self else { return }
            self.checkNextButton()
        }.disposed(by: disposeBag)
        
        passwordTextFieldInput.bind{[weak self] _ in
            guard let self = self else { return }
            self.checkNextButton()
        }.disposed(by: disposeBag)
        
        repeatPasswordTextFieldInput.bind{[weak self] _ in
            guard let self = self else { return }
            self.checkNextButton()
        }.disposed(by: disposeBag)
        
        phoneTextFieldInput.bind{[weak self] phone in
            guard let self = self else { return }
            self.phoneTextFieldOutput.accept(self.phoneFormat(with: "+X (XXX) XXX XX XX", phone: phone))
            self.checkNextButton()
        }.disposed(by: disposeBag)
        
        codeTextFieldInput.bind{[weak self] _ in
            guard let self = self else { return }
            self.checkNextButton()
        }.disposed(by: disposeBag)
        
    }
    
    //MARK: - Handlers
    func phoneButtonClick() {
        switch loginModeOutput.value {
        case .email, .password:
            loginModeOutput.accept(.phone)
        default:
            return
        }
    }
    
    func emailButtonClick() {
        switch loginModeOutput.value {
        case .phone, .code:
            loginModeOutput.accept(.email)
        default:
            return
        }
    }
    
    func nextButtonClick() {
        
        if nextButtonIsEnabledOutput.value == false  { return }
        
        switch loginModeOutput.value {
        case .email:
            loginModeOutput.accept(.password)
        case .phone:
            sendCode()
        case .password:
            isNewUser ? signUpWithEmail() : signInWithEmail()
        case .code:
            signUpWithPhone()
        }
    }
    
    func backButtonClick() {
        switch loginModeOutput.value {
        case .password:
            loginModeOutput.accept(.email)
        case .code:
            loginModeOutput.accept(.phone)
        case .email, .phone:
            steps.accept(AppStep.createAccountIsCompleted)
        }
    }
    
    func checkNextButton() {
        switch loginModeOutput.value {
        case .email:
            isValidEmail(emailTextFieldInput.value) ? nextButtonIsEnabledOutput.accept(true) : nextButtonIsEnabledOutput.accept(false)
        case .phone:
            phoneTextFieldInput.value == "" ? nextButtonIsEnabledOutput.accept(false) : nextButtonIsEnabledOutput.accept(true)
        case .password:
            if isNewUser {
                if passwordTextFieldInput.value != "",
                   passwordTextFieldInput.value == repeatPasswordTextFieldInput.value {
                    nextButtonIsEnabledOutput.accept(true)
                } else {
                    nextButtonIsEnabledOutput.accept(false)
                }
            } else {
                passwordTextFieldInput.value == "" ? nextButtonIsEnabledOutput.accept(false) : nextButtonIsEnabledOutput.accept(true)
            }
            
        case .code:
            codeTextFieldInput.value == "" ? nextButtonIsEnabledOutput.accept(false) : nextButtonIsEnabledOutput.accept(true)
        }
    }
    
    //MARK: - Auth Methods
    func signUpWithEmail() {
        services.networkAuthService.signUpWithEmail(withEmail: emailTextFieldInput.value, password: repeatPasswordTextFieldInput.value, fullname: "") { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.errorTextFieldOutput.accept(error.localizedDescription)
                return
            }
            self.steps.accept(AppStep.authIsCompleted)
        }
    }
    
    func signInWithEmail() {
        services.networkAuthService.signInWithEmail(withEmail: emailTextFieldInput.value, password: passwordTextFieldInput.value) {[weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.errorTextFieldOutput.accept(error.localizedDescription)
                return
            }
            self.steps.accept(AppStep.authIsCompleted)
        }
    }
    
    func sendCode() {
        var phone = phoneTextFieldOutput.value.replacingOccurrences(of: " ", with: "")
        phone = phone.replacingOccurrences(of: "(", with: "")
        phone = phone.replacingOccurrences(of: ")", with: "")
        services.networkAuthService.sendVerificationCodeWithPhone(withPhone: phone) {[weak self] verificationId, error in
            guard let self = self else { return }
            guard let verificationId = verificationId else { return }
            
            if let error = error {
                print(error.localizedDescription)
                self.errorTextFieldOutput.accept(error.localizedDescription)
                return
            }
            
            self.verificationId = verificationId
            self.loginModeOutput.accept(.code)
        }
    }
    
    func signUpWithPhone() {
        services.networkAuthService.signInWithPhone(verificationID: verificationId, verificationCode: codeTextFieldInput.value) {[weak self]  error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.errorTextFieldOutput.accept(error.localizedDescription)
                return
            }
            self.steps.accept(AppStep.authIsCompleted)
        }
    }
    
    //MARK: - Helpers
    func phoneFormat(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

