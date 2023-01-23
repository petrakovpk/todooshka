//
//  GIDSignIn+Rx.swift
//  Todooshka
//
//  Created by Pavel Petakov on 09.09.2022.
//

import FirebaseCore
import GoogleSignIn
import RxSwift
import RxCocoa

extension Reactive where Base: GIDSignIn {
  public func signIn(with presenting: UIViewController) -> Observable<Result<GIDSignInResult, Error>> {
    return Observable.create { observer in
      self.base.signIn(withPresenting: presenting) { result, error in
        if let result = result {
          observer.onNext(.success(result))
          observer.onCompleted()
        } else if let error = error {
          observer.onNext(.failure(error))
      }
      }
      return Disposables.create()
    }
  }
}
