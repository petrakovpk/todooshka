//
//  OTPCodeViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa

class OTPCodeViewModel: Stepper {
    let disposeBag = DisposeBag()
    let steps = PublishRelay<Step>()
    let verificationID: String

    // MARK: - Inputs
//    let OTPCodeTextInput = BehaviorRelay<String>(value: "")
//
// MARK: - Outputs
//    let OTPCodeTextOutput = BehaviorRelay<String>(value: "")
//    let errorTextOutput = BehaviorRelay<String>(value: "")
//    let isLoadingOutput = BehaviorRelay<Bool>(value: false)
//
    private let services: AppServices
//
    init(services: AppServices, verificationID: String) {
        self.services = services
        self.verificationID = verificationID

     //   bindInputsWithOutputs()
    }
//
//    func bindInputsWithOutputs() {
//        OTPCodeTextInput.subscribe(onNext: {[weak self] text in
//            guard let verificationID = self?.phoneFormat(with: "XXXXXX", phone: text) else { return }
//            self?.OTPCodeTextOutput.accept(verificationID)
//        }).disposed(by: disposeBag)
//
//        OTPCodeTextOutput.distinctUntilChanged { $0.count == $1.count }.subscribe(onNext: {[weak self] text in
//            if text.count == 6 { self?.logIn() }
//        }).disposed(by: disposeBag)
//    }
//
//    func logIn() {
//        isLoadingOutput.accept(true)
//        errorTextOutput.accept("")
//        if isValidVerificationCode() {
//            services.networkAuthService.signInWithPhone(verificationID: verificationID, verificationCode: OTPCodeTextInput.value) { [weak self] error in
//                guard let self = self else { return }
//                if let error = error {
//                    self.isLoadingOutput.accept(false)
//                    self.errorTextOutput.accept("Введите корректный OTP код")
//                    print(error.localizedDescription)
//                    return
//                }
//                self.steps.accept(AppStep.authIsCompleted)
//                self.isLoadingOutput.accept(false)
//            }
//        }
//    }
//
//    func phoneFormat(with mask: String, phone: String) -> String {
//        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
//        var result = ""
//        var index = numbers.startIndex // numbers iterator
//
//        // iterate over the mask characters until the iterator of numbers ends
//        for ch in mask where index < numbers.endIndex {
//            if ch == "X" {
//                // mask requires a number in this place, so take the next one
//                result.append(numbers[index])
//
//                // move numbers iterator to the next index
//                index = numbers.index(after: index)
//
//            } else {
//                result.append(ch) // just append a mask character
//            }
//        }
//        return result
//    }
//
//    func isValidVerificationCode() -> Bool {
//        var isValidCode = true
//        if OTPCodeTextInput.value.count != 6 {
//            isLoadingOutput.accept(false)
//            errorTextOutput.accept("Введите 6 цифр")
//            isValidCode = false
//        }
//        return isValidCode
//    }
}
