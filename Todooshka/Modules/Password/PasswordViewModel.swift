//
//  PasswordViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa

class PasswordViewModel: Stepper {

    let disposeBag = DisposeBag()
    let steps = PublishRelay<Step>()
    let email: String

    private let services: AppServices

    // MARK: - Inputs
    let passwordTextInput = BehaviorRelay<String>(value: "")
    let repeatPasswordTextInput = BehaviorRelay<String>(value: "")

    // MARK: - Outputs
    let isNewUser = BehaviorRelay<Bool>(value: false)
    let errorTextOutput = BehaviorRelay<String?>(value: "")
    let isLoadingOutput = BehaviorRelay<Bool>(value: false)

    init(services: AppServices, email: String, isNewUser: Bool) {
        self.services = services
        self.email = email
        self.isNewUser.accept(isNewUser)
    }

//    func isPasswordsCorrect() -> Bool {
//        isLoadingOutput.accept(true)
//        errorTextOutput.accept("")
//        if passwordTextInput.value == "" {
//            errorTextOutput.accept("Введите пароль")
//            isLoadingOutput.accept(false)
//            return false
//        }
//        
//        if isNewUser.value {
//            if repeatPasswordTextInput.value == "" {
//                errorTextOutput.accept("Повторно введите пароль")
//                isLoadingOutput.accept(false)
//                return false
//            }
//            
//            if passwordTextInput.value != repeatPasswordTextInput.value {
//                errorTextOutput.accept("Пароли не совпадают")
//                isLoadingOutput.accept(false)
//                return false
//            }
//        }
//        
//        return true
//    }
//    
//    func logIn() {
//        if isPasswordsCorrect() {
//            switch isNewUser.value {
//            case true:
//                services.networkAuthService.signUpWithEmail(withEmail: email, password: passwordTextInput.value, fullname: "") { [weak self] error in
//                    guard let self = self else { return }
//                    if let error = error {
//                        self.isLoadingOutput.accept(false)
//                        self.errorTextOutput.accept(error.localizedDescription)
//                        print(error.localizedDescription)
//                        return
//                    }
//                    self.steps.accept(AppStep.authIsCompleted)
//                    self.isLoadingOutput.accept(false)
//                }
//            case false:
//                services.networkAuthService.signInWithEmail(withEmail: email, password: passwordTextInput.value) { [weak self] result, error in
//                    guard let self = self else { return }
//                    if let error = error {
//                        self.isLoadingOutput.accept(false)
//                        self.errorTextOutput.accept(error.localizedDescription)
//                        print(error.localizedDescription)
//                        return
//                    }
//                    self.steps.accept(AppStep.authIsCompleted)
//                    self.isLoadingOutput.accept(false)
//                }
//            }
//        }
//    }
}
