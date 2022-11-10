//
//  NetworkServices.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 18.05.2021.
//

import Firebase
import GoogleSignIn
import RxSwift
import RxCocoa

protocol HasAuthServiceProtocol {
  var authService: AuthService { get }
}

// extension Observable where Element == SignUpWithEmailAttr {
//  func createUser(attr: SignUpWithEmailAttr) -> Observable<[String: Any]> {
//    return Observable<[String: Any]>.create { observer in
//      Auth.auth().createUser(withEmail: attr.email, password: attr.password) { result, error in
//        if let error = error {
//          print(error.localizedDescription)
//          observer.onError(error)
//        } else {
//          let values = [
//            "email": attr.email.uppercased() ,
//            "fullname": ""
//          ] as [String: Any]
//          observer.onNext(values)
//          observer.onCompleted()
//        }
//        
//      }
//      return Disposables.create()
//    }
//  }
// }

// extension SharedSequence where Element == SignUpWithEmailAttr {
//  func auth() -> SharedSequence<SharingStrategy, Void> {
//    return self.map { attr -> Void in
//      self.source.createUser(attr: attr)
//    }
//  }
// }

// Auth.auth().createUser(withEmail: email, password: password){ (result, error) in
//  if let error = error {
//    completion?(error)
//    print("\(error.localizedDescription)")
//    return
//  }
//
//  result?.user.sendEmailVerification(completion: { (error) in
//    if let error = error {
//      print("\(error.localizedDescription)")
//      return
//    }
//  })
//
//  let values = ["email": email.uppercased(),
//                "fullname": fullname ] as [String: Any]
//
//  self.update(with: values, completion: completion)
// }

class AuthService {
  // MARK: - Public

  // MARK: - Private
//  private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!
//  private let currentUser = BehaviorRelay<User?>(value: nil)

  // MARK: - Init
  init() {
//    authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener {[weak self] (auth, user) in
//      guard let self = self else { return }
//      if let user = user {
//        self.currentUser.accept(user)
//      } else {
//        self.currentUser.accept(nil)
//      }
//    }
  }

  // MARK: - Log in with Credentials
//  func signInWithCredentials(credential: AuthCredential, completion: TodooshkaCompletion?) {
//    Auth.auth().signIn(with: credential) {(result, error) in
//      if let error = error {
//        completion?(error)
//        print(error.localizedDescription)
//        return
//      }
//
//      guard let currentUser = result?.user else { return }
//      let email = currentUser.email
//      let fullname = currentUser.displayName
//      let values = ["email": email, "fullname": fullname] as [String: Any]
//      self.update(with: values, completion: completion)
//    }
//  }

  // MARK: - Sign in / Sign up with Email
//  func isNewUser(withEmail email: String, completion: @escaping( (_ isNewUser: Bool) -> Void )) {
//    USER_REF.queryOrdered(byChild: "email").queryEqual(toValue: email.trimmed.uppercased()).observeSingleEvent(of: .value) { dataSnapshot in
//      dataSnapshot.childrenCount == 0 ? completion(true) : completion(false)
//    }
//  }
//
//  func signInWithEmail(withEmail email:String, password: String, completion: AuthDataResultCallback?) {
//    Auth.auth().signIn(withEmail: email, password: password, completion: completion)
//  }
//
//  func signUpWithEmail(withEmail email:String, password: String, fullname: String,
//                       completion: TodooshkaCompletion? ) {
//    Auth.auth().createUser(withEmail: email, password: password){ (result, error) in
//      if let error = error {
//        completion?(error)
//        print("\(error.localizedDescription)")
//        return
//      }
//
//      result?.user.sendEmailVerification(completion: { (error) in
//        if let error = error {
//          print("\(error.localizedDescription)")
//          return
//        }
//      })
//
//      let values = ["email": email.uppercased(),
//                    "fullname": fullname ] as [String: Any]
//
//      self.update(with: values, completion: completion)
//    }
//  }
//
// MARK: - Sign in / Sign up with Phone
//  func sendVerificationCodeWithPhone(withPhone phone: String, completion: @escaping(VerificationResultCallback)) {
//    // Auth.auth().settings?.isAppVerificationDisabledForTesting = true
//    PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil, completion: completion)
//  }
//
//  func signInWithPhone(verificationID: String, verificationCode: String, completion: TodooshkaCompletion? ) {
//    completion?(nil)
//    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID , verificationCode: verificationCode)
//
//    Auth.auth().signIn(with: credential) { [weak self] (result, error) in
//      guard let self = self else { return }
//      if let error = error {
//        completion?(error)
//        print(error.localizedDescription)
//        return
//      }
//      guard let currentUser = result?.user else { return }
//      let phoneNumber = currentUser.phoneNumber
//      let values = ["phoneNumber": phoneNumber, "registeredBy": "phone" ] as [String: Any]
//
//      self.saveUserDataToFirebase(values: values, completion: completion)
//    }
//  }
//
// MARK: - Save user data to Database
//  func update(with values: [String: Any], completion: TodooshkaCompletion?) {
//
//    guard let user = Auth.auth().currentUser else {
//      completion?(ErrorType.UserNotFound)
//      return
//    }
//
//    USER_REF.child(user.uid).updateChildValues(values) { error, ref in
//      if let error = error {
//        print(error.localizedDescription)
//        completion?(error)
//        return
//      }
//    }
//
//  }
}
