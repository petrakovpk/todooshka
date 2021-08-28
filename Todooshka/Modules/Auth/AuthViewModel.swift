//
//  AuthViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 23.08.2021.
//

import RxFlow
import RxSwift
import RxCocoa

import Firebase
import GoogleSignIn
import AuthenticationServices

class AuthViewModel: Stepper {

    //MARK: - Properties
    let steps = PublishRelay<Step>()
    
    private let services: AppServices
    private let disposeBag = DisposeBag()
    
    //MARK: - Init
    init(services: AppServices) {
        self.services = services
    }
    
    //MARK: - Handler
    func googleButtonClick(viewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { [unowned self] user, error in

          if let error = error {
            print(error.localizedDescription)
            return
          }
            
            if let authentication = user?.authentication,
               let idToken = authentication.idToken {
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: authentication.accessToken)
                //
                logInWithCredential(credential: credential)
            }
        }
    }
    
    func logInWithCredential(credential: AuthCredential) {
        services.networkAuthService.signInWithCredentials(credential: credential) {[weak self] error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.steps.accept(AppStep.authIsCompleted)
        }
    }
    
    func skipButtonClick() {
        steps.accept(AppStep.authIsCompleted)
    }
   
    func createButtonClick() {
        steps.accept(AppStep.createAccountIsRequired(isNewUser: true))
    }
    
    func loginButtonClick() {
        steps.accept(AppStep.createAccountIsRequired(isNewUser: false))
    }
    
}
